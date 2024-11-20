import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:the_bridge_app/resources/models/resource.dart';

class PdfViewerPage extends StatefulWidget {
  final Resource resource;

  const PdfViewerPage({super.key, required this.resource});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? _localPath;
  bool _isLoading = true;
  String? _error;
  int? _totalPages;
  int _currentPage = 0;
  bool isReady = false;
  late PageController pageController;
  bool _showControls = true;
  PDFViewController? _pdfViewController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: _currentPage);
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.resource.url));

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.pdf');
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          _localPath = file.path;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load PDF: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading PDF: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          widget.resource.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          if (_totalPages != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Page ${_currentPage + 1} of $_totalPages',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading PDF...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_localPath != null) {
      return GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Stack(
          children: [
            PDFView(
              filePath: _localPath!,
              swipeHorizontal: true,
              enableSwipe: true,
              autoSpacing: false,
              pageFling: true,
              pageSnap: true,
              defaultPage: _currentPage,
              fitPolicy: FitPolicy.BOTH,
              backgroundColor: Colors.grey[900],
              onRender: (pages) {
                setState(() {
                  _totalPages = pages;
                  isReady = true;
                });
              },
              onViewCreated: (PDFViewController pdfViewController) {
                _pdfViewController = pdfViewController;
              },
              onPageChanged: (int? page, int? total) {
                if (page != null) {
                  setState(() {
                    _currentPage = page;
                  });
                }
              },
              onError: (error) {
                setState(() {
                  _error = error.toString();
                });
              },
            ),
            if (!isReady)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            if (_showControls && isReady)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous, color: Colors.white),
                        onPressed: _currentPage > 0
                            ? () {
                                setState(() => _currentPage--);
                                _pdfViewController?.setPage(_currentPage);
                              }
                            : null,
                      ),
                      Text(
                        '${_currentPage + 1} / $_totalPages',
                        style: const TextStyle(color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next, color: Colors.white),
                        onPressed: _currentPage < (_totalPages ?? 1) - 1
                            ? () {
                                setState(() => _currentPage++);
                                _pdfViewController?.setPage(_currentPage);
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return const Center(
      child: Text(
        'Something went wrong',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
