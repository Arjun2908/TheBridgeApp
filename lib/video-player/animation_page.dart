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
  int _currentStep = 0;
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
      if (_currentStep < steps.length) {
        _playStep();
        _currentStep++;
      }
    });
  }

  void _playStep() async {
    setState(() {
      _isPlaying = true;
    });

    Duration start = Duration(
      seconds: steps[_currentStep].startFrom.floor(),
      milliseconds: (steps[_currentStep].startFrom.remainder(1) * 1000).toInt(),
    );
    Duration end = Duration(
      seconds: steps[_currentStep].endAt.floor(),
      milliseconds: (steps[_currentStep].endAt.remainder(1) * 1000).toInt(),
    );

    await _initializeVideoPlayerFuture;

    bool seekSuccessful = false;
    const int maxRetries = 10;
    const Duration retryDelay = Duration(milliseconds: 500);
    int retryCount = 0;

    // Check if the video is initialized before seeking
    if (_controller.value.isInitialized) {
      while (!seekSuccessful && retryCount < maxRetries) {
        try {
          _controller.seekTo(start);
          await Future.delayed(const Duration(milliseconds: 100)); // Short delay to let seek take effect

          // Check if seek was successful
          if (_controller.value.position >= start && _controller.value.position <= start + const Duration(milliseconds: 100)) {
            seekSuccessful = true;
          } else {
            await Future.delayed(retryDelay);
          }
        } catch (error) {
          // Handle seek error
        }

        retryCount++;
        if (!seekSuccessful && retryCount < maxRetries) {
          await Future.delayed(retryDelay);
        }
      }
    } else {}

    if (!seekSuccessful) {
      setState(() {
        _isPlaying = false;
      });
      return; // Exit if seek operation fails
    }

    // Ensure video is not already playing and then start playback
    if (_controller.value.isInitialized && !_controller.value.isPlaying) {
      try {
        await _controller.play();
      } catch (error) {}
    } else {}

    // Delay for pausing only after confirming playback
    Future.delayed(end - start, () {
      if (_controller.value.isPlaying) {
        _controller.pause().catchError((error) {});
      }
      setState(() {
        _isPlaying = false;
      });
    });
  }

  void _prevStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
        _controller.seekTo(Duration(
          seconds: steps[_currentStep].startFrom.floor(),
          milliseconds: (steps[_currentStep].startFrom.remainder(1)).toInt(),
        ));
      }
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: _currentStep < 0 ? null : _prevStep,
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
              child: Text(steps[_currentStep == 0 ? 0 : _currentStep - 1].additionalText),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: _currentStep == steps.length ? null : _nextStep,
          child: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(253, 246, 222, 1.000),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(
          backgroundColor: const Color.fromRGBO(253, 246, 222, 1.000),
          // title: const Text('Bridge Diagram'),
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
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Container(
                padding: const EdgeInsets.only(left: 10, right: 20),
                // margin: const EdgeInsets.all(8.0),
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
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
        // height: 35,
        padding: const EdgeInsets.all(20),
        color: const Color.fromRGBO(253, 246, 222, 1.000),
        child: _buildFooterButtons(),
      ),
      // persistentFooterAlignment: AlignmentDirectional.center,
      // persistentFooterButtons: [
      //   Container(
      //     height: 35,
      //     color: const Color.fromRGBO(253, 246, 222, 1.000),
      //     child: _buildFooterButtons(),
      //   ),
      // ],
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
