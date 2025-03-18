import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';

class MyWebView extends StatefulWidget {
  const MyWebView({super.key});

  @override
  State<MyWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  late final WebViewController _controller;
  final String _url = 'https://onedesk.newuu.uz/en/auth/login';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _requestPermissions();
  }

  /// ✅ Android uchun ruxsatlarni so‘rash
  Future<void> _requestPermissions() async {
    await Permission.storage.request();
  }

  /// ✅ WebView ni ishga tushirish
  Future<void> _initializeWebView() async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            debugPrint("✅ Yuklandi: $url");
            await _getCookies(); // Cookie'larni olish
          },
          onNavigationRequest: (NavigationRequest request) {
            Uri uri = Uri.parse(request.url);

            if (uri.path.contains(RegExp(r'\.(pdf|jpg|jpeg|png|zip|rar|mp4|mp3|docx?|xlsx?|pptx?|txt|csv|apk|exe|iso|dmg|tar\.gz|7z|gif|webp|mov|avi|flv|mkv)$', caseSensitive: false))) {
              _downloadFile(request.url);
              return NavigationDecision.prevent; // ❌ WebView ichida ochilmaydi, yuklab olinadi
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_url));
  }

  /// ✅ **Cookie'larni olish**
  Future<void> _getCookies() async {
    final cookieManager = CookieManager.instance();
    List<Cookie> cookies = await cookieManager.getCookies(url: WebUri(_url));

    if (cookies.isNotEmpty) {
      String cookieString = cookies.map((c) => '${c.name}=${c.value}').join('; ');

      debugPrint("🍪 Olingan cookie: $cookieString");

    }
  }

  /// 🔙 **Orqaga qaytish tugmasi bosilganda**
  Future<bool> _handleBackButton() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    }
    return true;
  }

  /// 🔄 **Pastga scroll qilinganda sahifani yangilash**
  Future<void> _pullToRefresh() async {
    _controller.reload();
  }


  /// 📥 **Fayl yuklab olish funksiyasi (xatoliklarni qayta ishlash bilan)**
  Future<void> _downloadFile(String url) async {
    try {
      await FlutterDownloader.enqueue(
        url: url,
        savedDir: "/storage/emulated/0/Download/",
        fileName: "downloaded_file",
        showNotification: true,
        openFileFromNotification: true,
      );
      debugPrint("✅ Fayl yuklab olish boshlandi: $url");
    } catch (e) {
      debugPrint("❌ Xatolik yuz berdi: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fayl yuklashda xatolik yuz berdi!")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    // 🔹 Tizim rejimini olish
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: _handleBackButton,
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.white, // 📌 AppBar rangi
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(10), // 🔹 AppBar balandligi
          child: AppBar(
            backgroundColor: isDarkMode ? Colors.black : Colors.white, // 📌 AppBar rangi
            foregroundColor: isDarkMode ? Colors.white : Colors.black, // 📌 AppBar matn rangi
            elevation: 0,
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _pullToRefresh,
          child: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }
}
