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
  final String videoPath; // Path to the video file for this step
  final List<String>? verses; // List of related verses for this step
  final String info; // Additional information for this step
  final String additionalText; // Additional text for this step
  final String additionalDialogMessage; // Dialog message for this step

  Step({
    required this.videoPath,
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
  late VideoPlayerController? _nextController = VideoPlayerController.asset(steps[1].videoPath);
  late VideoPlayerController? _prevController = VideoPlayerController.asset(steps[0].videoPath);
  late Future<void> _initializeVideoPlayerFuture;
  late Future<void>? _initializeNextVideoPlayerFuture;
  late Future<void>? _initializePrevVideoPlayerFuture;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

    _loadVideoForStep(_currentStep);
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

    if (stepIndex > 0) {
      _prevController = VideoPlayerController.asset(steps[stepIndex - 1].videoPath);
      _initializePrevVideoPlayerFuture = _prevController!.initialize();
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
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
        // _initializeVideoPlayerFuture = _controller.initialize().then((_) {
        //   _controller.seekTo(Duration.zero); // Seek to the start
        //   _controller.play(); // Play the current video
        // });
      });
      _controller.play(); // Play the preloaded video

      // Preload the next video
      if (_currentStep < steps.length - 1) {
        _nextController = VideoPlayerController.asset(steps[_currentStep + 1].videoPath);
        _initializeNextVideoPlayerFuture = _nextController!.initialize();
      }

      // Preload the previous video
      if (_currentStep > 0) {
        _prevController = VideoPlayerController.asset(steps[_currentStep - 1].videoPath);
        _initializePrevVideoPlayerFuture = _prevController!.initialize();
      }
    }
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
    return Scaffold(
      backgroundColor: const Color.fromRGBO(253, 246, 222, 1.000),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(
          backgroundColor: const Color.fromRGBO(253, 246, 222, 1.000),
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
        padding: const EdgeInsets.all(20),
        color: const Color.fromRGBO(253, 246, 222, 1.000),
        child: _buildFooterButtons(),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:the_bridge_app/providers/passage_provider.dart';
// import 'package:video_player/video_player.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';

// import 'alt_consts.dart';

// class Step {
//   final String videoPath; // Path to the video file for this step
//   final List<String>? verses; // List of related verses for this step
//   final String info; // Additional information for this step
//   final String additionalText; // Additional text for this step
//   final String additionalDialogMessage; // Dialog message for this step

//   Step({
//     required this.videoPath,
//     required this.verses,
//     required this.info,
//     required this.additionalText,
//     required this.additionalDialogMessage,
//   });
// }

// Future<void> shareFiles() async {
//   final ByteData byteData = await rootBundle.load('assets/bridge_diagram.png');
//   final tempDir = await getTemporaryDirectory();
//   final file = await File('${tempDir.path}/bridge_diagram.png').writeAsBytes(
//     byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
//   );

//   final List<XFile> files = [XFile(file.path)];
//   Share.shareXFiles(files, fileNameOverrides: ['bridge_diagram.png']);
// }

// class AnimationPage extends StatefulWidget {
//   const AnimationPage({super.key});

//   @override
//   State<AnimationPage> createState() => _AnimationPageState();
// }

// class _AnimationPageState extends State<AnimationPage> {
//   late List<VideoPlayerController> _controllers;
//   late List<Future<void>> _initializeFutures;
//   int _currentStep = 0;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsFlutterBinding.ensureInitialized();
//     SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

//     _loadAllControllers();
//   }

//   void _loadAllControllers() {
//     _controllers = steps.map((step) {
//       return VideoPlayerController.asset(step.videoPath);
//     }).toList();

//     _initializeFutures = _controllers.map((controller) {
//       return controller.initialize();
//     }).toList();

//     // Start playing the first video once it's initialized
//     _initializeFutures[0].then((_) {
//       setState(() {
//         _controllers[_currentStep].play();
//       });
//     });
//   }

//   void _getVerse(String verse) {
//     context.read<PassagesProvider>().fetchPassages(verse);
//   }

//   void _showVerses() {
//     _getVerse(steps[_currentStep].verses!.join(' '));
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           content: Consumer<PassagesProvider>(
//             builder: (context, passageProvider, child) {
//               if (passageProvider.isLoading) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (passageProvider.passages != null) {
//                 return SingleChildScrollView(child: Text(passageProvider.passages!.map((passage) => passage.text).join('\n\n')));
//               }
//               return const Center(child: Text('Enter a passage to fetch'));
//             },
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showMoreInfo() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           content: SingleChildScrollView(child: Text(steps[_currentStep].info)),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showAdditionalInfo() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           content: SingleChildScrollView(child: Text(steps[_currentStep].additionalDialogMessage)),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   void _nextStep() async {
//     if (_currentStep < steps.length - 1) {
//       await _controllers[_currentStep].pause(); // Pause current video
//       await _controllers[_currentStep + 1].seekTo(Duration.zero); // Reset the video
//       setState(() {
//         _currentStep++;
//       });
//       _controllers[_currentStep].play(); // Play the next video
//     }
//   }

//   void _prevStep() async {
//     if (_currentStep > 0) {
//       await _controllers[_currentStep].pause(); // Pause current video
//       await _controllers[_currentStep - 1].seekTo(Duration.zero); // Reset the video
//       setState(() {
//         _currentStep--;
//       });
//       _controllers[_currentStep].play(); // Play the previous video
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromRGBO(253, 246, 222, 1.000),
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(50.0),
//         child: AppBar(
//           backgroundColor: const Color.fromRGBO(253, 246, 222, 1.000),
//           actions: [
//             IconButton(
//               onPressed: shareFiles,
//               icon: const Icon(Icons.share),
//             ),
//           ],
//         ),
//       ),
//       body: GestureDetector(
//         onHorizontalDragEnd: (details) {
//           if (details.primaryVelocity! < 0) {
//             _nextStep();
//           } else if (details.primaryVelocity! > 0) {
//             _prevStep();
//           }
//         },
//         child: FutureBuilder(
//           future: _initializeFutures[_currentStep],
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.done) {
//               return Container(
//                 padding: const EdgeInsets.only(left: 10, right: 20),
//                 child: SizedBox.expand(
//                   child: FittedBox(
//                     fit: BoxFit.fill,
//                     child: SizedBox(
//                       width: _controllers[_currentStep].value.size.width,
//                       height: _controllers[_currentStep].value.size.height,
//                       child: VideoPlayer(_controllers[_currentStep]),
//                     ),
//                   ),
//                 ),
//               );
//             } else {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             }
//           },
//         ),
//       ),
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.all(20),
//         color: const Color.fromRGBO(253, 246, 222, 1.000),
//         child: _buildFooterButtons(),
//       ),
//     );
//   }

//   Widget _buildFooterButtons() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         ElevatedButton(
//           onPressed: _currentStep <= 0 ? null : _prevStep,
//           child: const Icon(Icons.chevron_left),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: _showVerses,
//               child: const Text('Show Verses'),
//             ),
//             const SizedBox(width: 20),
//             ElevatedButton(
//               onPressed: _showAdditionalInfo,
//               child: Text(steps[_currentStep].additionalText),
//             ),
//           ],
//         ),
//         ElevatedButton(
//           onPressed: _currentStep >= steps.length - 1 ? null : _nextStep,
//           child: const Icon(Icons.chevron_right),
//         ),
//       ],
//     );
//   }
// }
