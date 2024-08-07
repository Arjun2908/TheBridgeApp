import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:the_bridge_app/providers/passage_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'consts.dart';

class Step {
  final double startFrom; // Start time in seconds for this step
  final double endAt; // End time in seconds for this step
  final List<String>? verses; // List of related verses for this step
  final String info; // Additional information for this step
  final String additionalText; // Additional text for this step
  final String additionalDialogMessage; // Dialog message for this step

  Step({
    required this.startFrom,
    required this.endAt,
    required this.verses,
    required this.info,
    required this.additionalText,
    required this.additionalDialogMessage,
  });
}

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
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  int _currentStep = -1;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

    _controller = VideoPlayerController.asset("assets/bridge_diagram.mp4");
    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    _controller.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() {
      if (_currentStep < steps.length - 1) {
        _currentStep++;
        _playStep();
      }
    });
  }

  void _prevStep() {
    setState(() {
      if (_currentStep > 0) {
        _controller.seekTo(Duration(seconds: steps[_currentStep].startFrom.floor(), milliseconds: steps[_currentStep].startFrom.remainder(1).toInt()));
        _currentStep--;
      }
    });
  }

  void _playStep() {
    setState(() {
      _isPlaying = true;
    });

    Duration start = Duration(seconds: steps[_currentStep].startFrom.floor(), milliseconds: steps[_currentStep].startFrom.remainder(1).toInt());
    Duration end = Duration(seconds: steps[_currentStep].endAt.floor(), milliseconds: steps[_currentStep].endAt.remainder(1).toInt());

    _controller.seekTo(start);
    _controller.play();

    Future.delayed(end - start, () {
      _controller.pause();
      setState(() {
        _isPlaying = false;
      });
    });
  }

  void _getVerse(String verse) {
    context.read<PassagesProvider>().fetchPassages(verse);
  }

  void _showVerses() {
    _getVerse(steps[_currentStep].verses!.join(' '));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Consumer<PassagesProvider>(
            builder: (context, passageProvider, child) {
              if (passageProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (passageProvider.passages != null) {
                return SingleChildScrollView(child: Text(passageProvider.passages!.map((passage) => passage.text).join('\n\n')));
              }
              return const Center(child: Text('Enter a passage to fetch'));
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showMoreInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SingleChildScrollView(child: Text(steps[_currentStep].info)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _startOver() {
    setState(() {
      _currentStep = -1;
      _controller.seekTo(Duration.zero);
    });
  }

  void _showAdditionalInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SingleChildScrollView(child: Text(steps[_currentStep].additionalDialogMessage)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
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
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: _showMoreInfo,
          child: const Text('More Info'),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: _startOver,
          child: const Text('Start Over'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(
          title: const Text('Bridge Diagram'),
          actions: [
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
        child: Stack(
          children: [
            FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
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
            Positioned(
              top: 10,
              left: 10,
              child: ElevatedButton(
                onPressed: _isPlaying || _currentStep <= 0 ? null : _prevStep,
                child: const Icon(Icons.chevron_left),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: ElevatedButton(
                onPressed: _isPlaying || _currentStep == steps.length - 1 ? null : _nextStep,
                child: const Icon(Icons.chevron_right),
              ),
            ),
          ],
        ),
      ),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        SizedBox(
          height: 35,
          child: _buildFooterButtons(),
        ),
      ],
    );
  }
}
// TODO:

// 1. ESV API support - done
// 2. export at the end - done
// 3. add about - done
// 4. add settings - done
// 5. add help/tutorial
// 6. do we wanna add audio to parts?
// 7. add drawing canvas
// 8. bring back portrait mode for other pages - done
// 9. add caching for esv api
