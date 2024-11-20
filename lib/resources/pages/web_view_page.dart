import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:the_bridge_app/resources/models/resource.dart';

class WebViewPage extends StatefulWidget {
  final Resource resource;

  const WebViewPage({super.key, required this.resource});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(),
      )
      ..loadRequest(Uri.parse(widget.resource.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.resource.title),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
        ],
      ),
    );
  }
}
