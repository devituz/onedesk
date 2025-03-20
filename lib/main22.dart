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
  final CookieManager _cookieManager = CookieManager();
  final String _url = 'https://onedesk.newuu.uz/en/auth/login';

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
  }

  /// Request storage permissions (handle Android 13+ properly)
  Future<void> requestStoragePermission() async {
    if (await Permission.manageExternalStorage.request().isGranted) {
      print("Storage permission granted");
    } else {
      print("Storage permission denied");
    }
  }

  /// Load cookies before opening WebView
  Future<void> _loadCookies() async {
    List<Cookie> cookies = await _cookieManager.getCookies(url: WebUri(_url));
    for (var cookie in cookies) {
      await _cookieManager.setCookie(
        url: WebUri(_url),
        name: cookie.name,
        value: cookie.value,
        domain: "onedesk.newuu.uz",
        isSecure: true,
      );
    }
  }

  /// Print cookies after the page is loaded
  Future<void> _printCookies() async {
    List<Cookie> cookies = await _cookieManager.getCookies(url: WebUri(_url));
    for (var cookie in cookies) {
      print("Cookie: ${cookie.name} = ${cookie.value}");
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
          hardwareAcceleration: false,
          javaScriptEnabled: true,
          useOnDownloadStart: true,
          allowsInlineMediaPlayback: true,
          userAgent:
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          cacheEnabled: true,
          clearCache: false,
          supportMultipleWindows: true,
          thirdPartyCookiesEnabled: true,
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;
          _loadCookies();
        },
        onLoadStop: (controller, url) async {
          if (url != null) {
            await _loadCookies();
            print("Page loaded: $url");
            await _printCookies(); // Print cookies after the page loads
          }
        },
        onDownloadStartRequest: (controller, request) async {
          print("Download requested: ${request.url}");
          await _downloadFile(request.url.toString());
        },
      ),
    );
  }

  /// Download file and handle storage correctly
  Future<void> _downloadFile(String url) async {
    print("Starting download for: $url");

    final directory = await getExternalStorageDirectory();
    final savedDir = directory?.path ?? "";

    if (savedDir.isNotEmpty) {
      try {
        await FlutterDownloader.enqueue(
          url: "https://pub.dev/static/hash-pb35dgsm/img/pub-dev-logo.svg",
          savedDir: savedDir,
          showNotification: true,
          openFileFromNotification: true,
          saveInPublicStorage: true,
        );
        print("Download enqueued successfully.");
      } catch (e) {
        print("Download failed: $e");
      }
    } else {
      print("Failed to get storage directory.");
    }
  }
}
