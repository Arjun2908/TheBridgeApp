import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:scribble/scribble.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';

import 'package:the_bridge_app/models/note.dart';
import 'package:the_bridge_app/providers/notes_provider.dart';
import 'package:the_bridge_app/providers/passage_provider.dart';
import 'package:the_bridge_app/global_helpers.dart';

import 'consts.dart';

Future<void> shareFiles() async {
  final ByteData byteData = await rootBundle.load('assets/bridge_diagram.png');
  final tempDir = await getTemporaryDirectory();
  final file = await File('${tempDir.path}/bridge_diagram.png').writeAsBytes(
    byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
  );

  final List<XFile> files = [XFile(file.path)];
  Share.shareXFiles(files, fileNameOverrides: ['bridge_diagram.png']);
}

class AnimationPage extends StatefulWidget {
  const AnimationPage({super.key});

  @override
  State<AnimationPage> createState() => _AnimationPageState();
}

class _AnimationPageState extends State<AnimationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<VideoPlayerController> _controllers;
  late VideoPlayerController _currentController;
  late Future<void> _initializeVideoPlayersFuture;
  int _currentStep = 0;
  String _drawerContent = '';
  final ScribbleNotifier _scribbleNotifier = ScribbleNotifier();
  bool showScribble = false;
  bool audioEnabled = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    // Initialize all controllers at once
    _controllers = List.generate(
      steps.length,
      (index) => VideoPlayerController.asset(steps[index].videoPath),
    );

    // Initialize all controllers and set current controller
    _initializeVideoPlayersFuture = Future.wait(
      _controllers.map((controller) => controller.initialize()),
    ).then((_) {
      _currentController = _controllers[_currentStep];
      _currentController.play();
      setState(() {});
    });

    FToastBuilder();

    // Add audio completion listener
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isAudioPlaying = false;
      });
    });
  }

  Widget _buildDrawingToolbar() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 40),
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: _scribbleNotifier.undo,
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          onPressed: _scribbleNotifier.redo,
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: _scribbleNotifier.clear,
        ),
        IconButton(
          icon: const Icon(Icons.brush),
          onPressed: () {
            _scribbleNotifier.setColor(Colors.black); // Use brush
          },
        ),
        IconButton(
          icon: const Icon(MaterialCommunityIcons.eraser),
          onPressed: () {
            _scribbleNotifier.setEraser(); // Use eraser
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    for (var controller in _controllers) {
      controller.dispose();
    }
    _scribbleNotifier.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _nextStep() async {
    if (_currentStep < steps.length - 1) {
      await _audioPlayer.stop();
      setState(() {
        _isAudioPlaying = false;
      });

      // Pause current video first
      await _currentController.pause();

      // Prepare next video before showing it
      final nextController = _controllers[_currentStep + 1];
      await nextController.seekTo(Duration.zero);
      await nextController.pause(); // Ensure it's paused at the start

      setState(() {
        _currentStep++;
        _currentController = nextController;
      });

      // Start playing after state is updated
      _currentController.play();

      if (audioEnabled) {
        await _playCurrentStepAudio();
      }
    }
  }

  void _prevStep() async {
    if (_currentStep > 0) {
      await _audioPlayer.stop();
      setState(() {
        _isAudioPlaying = false;
      });

      // Pause current video first
      await _currentController.pause();

      // Prepare previous video before showing it
      final prevController = _controllers[_currentStep - 1];
      await prevController.seekTo(Duration.zero);
      await prevController.pause(); // Ensure it's paused at the start

      setState(() {
        _currentStep--;
        _currentController = prevController;
      });

      // Start playing after state is updated
      _currentController.play();

      if (audioEnabled) {
        await _playCurrentStepAudio();
      }
    }
  }

  void _getVerse(String verse) {
    context.read<PassagesProvider>().fetchPassages(verse);
  }

  void _getNotes() {
    context.read<NotesProvider>().fetchNotes();
  }

  void _showVerses() {
    _getVerse(steps[_currentStep].verses!.join(' '));
    setState(() {
      _drawerContent = 'verses';
    });
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _showAdditionalInfo() {
    setState(() {
      _drawerContent = 'additionalInfo';
    });
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _showNotes() {
    _getNotes();
    setState(() {
      _drawerContent = 'notes';
    });
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void toggleAudio() async {
    setState(() {
      audioEnabled = !audioEnabled;
    });

    if (audioEnabled) {
      await _playCurrentStepAudio();
    } else {
      await _audioPlayer.stop();
      setState(() {
        _isAudioPlaying = false;
      });
    }
  }

  Future<void> _playCurrentStepAudio() async {
    if (!audioEnabled) return;

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(steps[_currentStep].audioPath));
      setState(() {
        _isAudioPlaying = true;
      });
    } catch (e) {
      print('Error playing audio: $e');
      setState(() {
        _isAudioPlaying = false;
      });
    }
  }

  Widget _buildDrawerContent() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: _buildDrawerBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    String title = '';
    IconData headerIcon = Icons.info;

    switch (_drawerContent) {
      case 'verses':
        title = 'Bible Verses';
        headerIcon = Icons.menu_book;
        break;
      case 'additionalInfo':
        title = steps[_currentStep].additionalText;
        headerIcon = Icons.info_outline;
        break;
      case 'notes':
        title = 'Notes';
        headerIcon = Icons.note;
        break;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 4, 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(headerIcon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerBody() {
    switch (_drawerContent) {
      case 'verses':
        return _buildVersesContent();
      case 'additionalInfo':
        return _buildAdditionalInfoContent();
      case 'notes':
        return _buildNotesContent();
      default:
        return Container();
    }
  }

  Widget _buildVersesContent() {
    return Consumer<PassagesProvider>(
      builder: (context, passageProvider, child) {
        if (passageProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (passageProvider.passages != null) {
          return Column(
            children: [
              Builder(
                builder: (context) => _buildShareButton(
                  onPressed: () async {
                    final versesText = passageProvider.passages!.map((passage) => passage.text).join('\n\n');
                    final box = context.findRenderObject() as RenderBox?;
                    await Share.share(
                      '$versesText\n\nShared from The Bridge App',
                      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
                    );
                  },
                  text: 'Share Verses',
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: passageProvider.passages!.map((passage) {
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          passage.text,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        }
        return const Center(child: Text('No verses available'));
      },
    );
  }

  Widget _buildAdditionalInfoContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            steps[_currentStep].additionalDialogMessage,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesContent() {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        List<Note> notesToShow = notesProvider.notes;

        return Column(
          children: [
            Expanded(
              child: notesToShow.isEmpty ? _buildEmptyNotesState() : _buildNotesList(notesToShow),
            ),
            // _buildAddNoteButton(),
          ],
        );
      },
    );
  }

  Widget _buildNotesList(List<Note> notes) {
    return ListView.builder(
      itemCount: notes.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final note = notes[index];
        return Dismissible(
          key: Key(note.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            context.read<NotesProvider>().deleteNoteById(note.id!);
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                note.content,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(formatTimestamp(note.timestamp)),
              // onTap: () => _showEditNoteDialog(note),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyNotesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notes yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add a note',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNoteButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: _showAddNoteDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Note'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  void _showAddNoteDialog() {
    TextEditingController noteController = TextEditingController();
    FocusNode focusNode = FocusNode();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.note_add,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Add Note',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: TextField(
                      controller: noteController,
                      focusNode: focusNode,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                      decoration: const InputDecoration(
                        hintText: 'Write your thoughts here...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilledButton.icon(
                        onPressed: () {
                          if (noteController.text.isNotEmpty) {
                            final newNote = Note(
                              content: noteController.text,
                              step: _currentStep,
                              timestamp: DateTime.now(),
                            );
                            context.read<NotesProvider>().addNote(newNote);
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Save'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) => focusNode.dispose());

    Future.delayed(const Duration(milliseconds: 100), () {
      focusNode.requestFocus();
    });
  }

  void _showEditNoteDialog(Note note) {
    TextEditingController noteController = TextEditingController(text: note.content);
    FocusNode focusNode = FocusNode();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.edit_note,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Edit Note',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: TextField(
                      controller: noteController,
                      focusNode: focusNode,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                      decoration: const InputDecoration(
                        hintText: 'Write your thoughts here...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilledButton.icon(
                        onPressed: () {
                          if (noteController.text.isNotEmpty) {
                            note.content = noteController.text;
                            context.read<NotesProvider>().updateNoteContent(note);
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Save'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) => focusNode.dispose());

    Future.delayed(const Duration(milliseconds: 100), () {
      focusNode.requestFocus();
    });
  }

  Widget _buildShareButton({
    required VoidCallback onPressed,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.share),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterButtons() {
    if (_currentStep == -1) {
      return Container();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: _currentStep <= 0 ? null : _prevStep,
          child: const Icon(Icons.chevron_left),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _showVerses,
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Verses'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _showAdditionalInfo,
                  icon: const Icon(Icons.info_outline),
                  label: Text(steps[_currentStep].additionalText),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ],
            ),
            if (showScribble) _buildDrawingToolbar(),
          ],
        ),
        ElevatedButton(
          onPressed: _currentStep >= steps.length - 1 ? null : _nextStep,
          child: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? Colors.black : const Color.fromRGBO(253, 246, 222, 1.000),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(
          backgroundColor: isDarkMode ? Colors.black : const Color.fromRGBO(253, 246, 222, 1.000),
          actions: [
            IconButton(
              onPressed: toggleAudio,
              icon: Icon(audioEnabled ? (_isAudioPlaying ? Icons.volume_up : Icons.volume_down) : Icons.volume_off),
            ),
            IconButton(
              onPressed: () {
                _showNotes();
              },
              icon: const Icon(Icons.note_add),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  showScribble = !showScribble;
                });
              },
              icon: const Icon(Icons.draw),
            ),
            IconButton(
              onPressed: () {
                shareFiles();
              },
              icon: const Icon(Icons.share),
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            _nextStep();
          } else if (details.primaryVelocity! > 0) {
            _prevStep();
          }
        },
        child: FutureBuilder(
          future: _initializeVideoPlayersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Container(
                padding: const EdgeInsets.only(left: 45, right: 45),
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: SizedBox(
                      width: _currentController.value.size.width,
                      height: _currentController.value.size.height,
                      child: Stack(
                        children: [
                          isDarkMode
                              ? ColorFiltered(
                                  colorFilter: const ColorFilter.matrix([
                                    -1,
                                    0,
                                    0,
                                    0,
                                    230,
                                    0,
                                    -1,
                                    0,
                                    0,
                                    230,
                                    0,
                                    -0.236,
                                    -1,
                                    0,
                                    255,
                                    0,
                                    0,
                                    0,
                                    1,
                                    0,
                                  ]),
                                  child: VideoPlayer(_currentController),
                                )
                              : VideoPlayer(_currentController),
                          if (showScribble)
                            isDarkMode
                                ? ColorFiltered(
                                    colorFilter: const ColorFilter.matrix([
                                      -1,
                                      0,
                                      0,
                                      0,
                                      230,
                                      0,
                                      -1,
                                      0,
                                      0,
                                      230,
                                      0,
                                      -0.236,
                                      -1,
                                      0,
                                      255,
                                      0,
                                      0,
                                      0,
                                      1,
                                      0,
                                    ]),
                                    child: Scribble(notifier: _scribbleNotifier, drawPen: true),
                                  )
                                : Scribble(notifier: _scribbleNotifier, drawPen: true),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
      bottomNavigationBar: Container(
        // top 10 padding, bottom 10 padding, left 20 padding, right 20 padding
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        color: isDarkMode ? Colors.black : const Color.fromRGBO(253, 246, 222, 1.000),
        child: _buildFooterButtons(),
      ),
      endDrawer: Drawer(
        child: _buildDrawerContent(),
      ),
    );
  }
}
