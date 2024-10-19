import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:the_bridge_app/models/note.dart';
import 'package:the_bridge_app/providers/notes_provider.dart';
import 'package:the_bridge_app/providers/passage_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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

String formatTimestamp(DateTime dateTime) {
  // Format the DateTime object to a human-readable string
  String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

  return formattedDate;
}

class AnimationPage extends StatefulWidget {
  const AnimationPage({super.key});

  @override
  State<AnimationPage> createState() => _AnimationPageState();
}

class _AnimationPageState extends State<AnimationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late VideoPlayerController _controller;
  VideoPlayerController? _nextController = VideoPlayerController.asset(steps[1].videoPath);
  VideoPlayerController? _prevController = VideoPlayerController.asset(steps[0].videoPath);
  late Future<void> _initializeVideoPlayerFuture;
  Future<void>? _initializeNextVideoPlayerFuture;
  Future<void>? _initializePrevVideoPlayerFuture;
  int _currentStep = 0;
  String _drawerContent = '';

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    _loadVideoForStep(_currentStep);
    FToastBuilder();
  }

  void _loadVideoForStep(int stepIndex) {
    _controller = VideoPlayerController.asset(steps[stepIndex].videoPath);
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      setState(() {});
      _controller.play(); // Play the current video automatically
    });

    // Preload the next video if it's available
    if (stepIndex < steps.length - 1) {
      _nextController = VideoPlayerController.asset(steps[stepIndex + 1].videoPath);
      _initializeNextVideoPlayerFuture = _nextController!.initialize();
    }

    // Preload the previous video if it's available
    if (stepIndex > 0) {
      _prevController = VideoPlayerController.asset(steps[stepIndex - 1].videoPath);
      _initializePrevVideoPlayerFuture = _prevController!.initialize();
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _controller.dispose();
    _nextController?.dispose();
    _prevController?.dispose();
    super.dispose();
  }

  void _nextStep() async {
    if (_currentStep < steps.length - 1) {
      await _controller.pause(); // Pause current video
      await _nextController?.seekTo(Duration.zero); // Seek to the start

      setState(() {
        _currentStep++;
        _controller = _nextController!; // Swap to the preloaded next video
      });

      _controller.play(); // Play the preloaded video

      // Preload the next video if possible
      if (_currentStep < steps.length - 1) {
        _nextController = VideoPlayerController.asset(steps[_currentStep + 1].videoPath);
        _initializeNextVideoPlayerFuture = _nextController!.initialize();
      }

      // Preload the previous video if possible
      if (_currentStep > 0) {
        _prevController = VideoPlayerController.asset(steps[_currentStep - 1].videoPath);
        _initializePrevVideoPlayerFuture = _prevController!.initialize();
      }
    }
  }

  void _prevStep() async {
    if (_currentStep > 0) {
      await _controller.pause(); // Pause current video
      await _prevController?.seekTo(Duration.zero); // Seek to the start

      setState(() {
        _currentStep--;
        _controller = _prevController!; // Swap to the preloaded previous video
      });

      _controller.play(); // Play the preloaded video

      // Preload the previous video if possible
      if (_currentStep > 0) {
        _prevController = VideoPlayerController.asset(steps[_currentStep - 1].videoPath);
        _initializePrevVideoPlayerFuture = _prevController!.initialize();
      }

      // Preload the next video if possible
      if (_currentStep < steps.length - 1) {
        _nextController = VideoPlayerController.asset(steps[_currentStep + 1].videoPath);
        _initializeNextVideoPlayerFuture = _nextController!.initialize();
      }
    }
  }

  void _getVerse(String verse) {
    context.read<PassagesProvider>().fetchPassages(verse);
  }

  void _getNotes() {
    context.read<NotesProvider>().fetchNotes();
  }

  void _getNotesForCurrentStep() {
    context.read<NotesProvider>().fetchAllByStepId(_currentStep);
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

  bool _showGlobalNotes = true; // Toggle between global and step-specific notes
  void _showNotes() {
    _showGlobalNotes ? _getNotes() : _getNotesForCurrentStep();
    setState(() {
      _drawerContent = 'notes';
    });
    _scaffoldKey.currentState?.openEndDrawer();
  }

  Widget _buildDrawerContent() {
    if (_drawerContent == 'verses') {
      return Stack(
        children: [
          Consumer<PassagesProvider>(
            builder: (context, passageProvider, child) {
              if (passageProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (passageProvider.passages != null) {
                final versesText = passageProvider.passages!.map((passage) => passage.text).join('\n\n');
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
                    child: Text(versesText),
                  ),
                );
              }
              return const Center(child: Text('Enter a passage to fetch'));
            },
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.ios_share),
              onPressed: () async {
                var toast = FToast();
                toast.init(context);
                final passageProvider = context.read<PassagesProvider>();
                if (passageProvider.passages != null) {
                  final versesText = passageProvider.passages!.map((passage) => passage.text).join('\n\n');
                  final shareText = '$versesText\n\nShared from The Bridge App';
                  await Share.share(shareText);
                  toast.showToast(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0),
                        color: Colors.black54,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, color: Colors.white),
                          SizedBox(width: 12.0),
                          Text('Verses shared successfully', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      );
    } else if (_drawerContent == 'additionalInfo') {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
          child: Text(steps[_currentStep].additionalDialogMessage),
        ),
      );
    } else if (_drawerContent == 'notes') {
      return Consumer<NotesProvider>(
        builder: (context, notesProvider, child) {
          List<Note> notesToShow = _showGlobalNotes ? notesProvider.notes : notesProvider.notes.where((note) => note.step == _currentStep).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: const Text('Notes'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: _showGlobalNotes,
                      onChanged: (value) {
                        setState(() {
                          _showGlobalNotes = value;
                          _showNotes(); // Refresh the notes list
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _showAddNoteDialog,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: notesToShow.isNotEmpty
                    ? ListView.builder(
                        itemCount: notesToShow.length,
                        itemBuilder: (context, index) {
                          final note = notesToShow[index];
                          return Dismissible(
                            key: Key(note.id.toString()),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) {
                              context.read<NotesProvider>().deleteNoteById(note.id!);
                            },
                            background: Container(color: Colors.red),
                            child: ListTile(
                              title: Text(note.content),
                              subtitle: Text('${steps[note.step].additionalText} - ${formatTimestamp(note.timestamp)}'),
                              onTap: () {
                                _showEditNoteDialog(note);
                              },
                            ),
                          );
                        },
                      )
                    : const Center(child: Text('No notes available')),
              ),
            ],
          );
        },
      );
    }
    return Container();
  }

  void _showAddNoteDialog() {
    TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Note'),
          content: TextField(
            controller: noteController,
            decoration: const InputDecoration(hintText: 'Enter your note here'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (noteController.text.isNotEmpty) {
                  final newNote = Note(
                    content: noteController.text,
                    step: _currentStep,
                    timestamp: DateTime.now(),
                  );
                  context.read<NotesProvider>().addNote(newNote);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditNoteDialog(Note note) {
    TextEditingController noteController = TextEditingController(text: note.content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Note'),
          content: TextField(
            controller: noteController,
            decoration: const InputDecoration(hintText: 'Edit your note here'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (noteController.text.isNotEmpty) {
                  note.content = noteController.text;
                  context.read<NotesProvider>().updateNoteContent(note);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _showVerses,
              child: const Text('Show Verses'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: _showAdditionalInfo,
              child: Text(steps[_currentStep].additionalText),
            ),
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
              onPressed: () {
                _showNotes();
              },
              icon: const Icon(Icons.note_add),
            ),
            IconButton(
              onPressed: () {
                shareFiles();
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
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Container(
                padding: const EdgeInsets.only(left: 45, right: 45),
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: isDarkMode
                          ? ColorFiltered(
                              colorFilter: const ColorFilter.matrix([
                                -1, 0, 0, 0, 230, // Red
                                0, -1, 0, 0, 230, // Green
                                0, -0.236, -1, 0, 255, // Blue
                                0, 0, 0, 1, 0, // Alpha
                              ]),
                              child: VideoPlayer(_controller),
                            )
                          : VideoPlayer(_controller),
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
