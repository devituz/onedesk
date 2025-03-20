import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class MyWebView extends StatefulWidget {
  const MyWebView({super.key});

  @override
  State<MyWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  late InAppWebViewController _webViewController;
  final String _url = 'https://onedesk.newuu.uz/en/auth/login';

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView'),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(_url)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          useOnDownloadStart: true,
          allowsInlineMediaPlayback: true,
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        onDownloadStart: (controller, url) async {
          final directory = await getExternalStorageDirectory();
          final savedDir = directory?.path ?? "";

          if (savedDir.isNotEmpty) {
            await FlutterDownloader.enqueue(
              url: url.toString(),
              savedDir: savedDir,
              showNotification: true,
              openFileFromNotification: true,
            );
          }
        },
      ),
    );
  }
}
