import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyWebView(),
    );
  }
}

class MyWebView extends StatefulWidget {
  const MyWebView({super.key});

  @override
  State<MyWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  late final WebViewController _controller;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();

    // WebViewController yaratish
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // JavaScript yoqilgan
      ..setUserAgent(
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36') // User Agent
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint("⏳ Yuklanmoqda: $url");
          },
          onPageFinished: (String url) {
            debugPrint("✅ Yuklandi: $url");
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("❌ Xatolik: ${error.description}");
            setState(() {
              errorMessage = "Xatolik: ${error.description}";
            });
            showError("Internet yoki sahifa muammosi: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse('https://onedesk.newuu.uz/en/auth/login')); // URL yuklash
  }

  // Xatolik ko‘rsatish funksiyasi
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _controller.canGoBack()) {
          _controller.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("WebView"),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _controller.reload(); // Sahifani qayta yuklash
              },
            ),
          ],
        ),
        body: errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
            : WebViewWidget(controller: _controller),
      ),
    );
  }
}
