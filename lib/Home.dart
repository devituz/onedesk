import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


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

  /// Request both storage and manage external storage permissions

  Future<void> requestStoragePermission() async {
    // Ruxsatlarni tekshiramiz
    var storageStatus = await Permission.storage.status;
    var manageStorageStatus = await Permission.manageExternalStorage.status;

    if (storageStatus.isGranted && manageStorageStatus.isGranted) {
      print("Barcha kerakli ruxsatlar allaqachon berilgan.");
      return;
    }

    // Agar ruxsat rad etilgan bo‘lsa, qayta so‘raymiz
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.manageExternalStorage, // Android 10+ uchun
    ].request();

    if (statuses[Permission.storage]!.isGranted && statuses[Permission.manageExternalStorage]!.isGranted) {
      print("Barcha kerakli ruxsatlar berildi.");
    } else if (statuses[Permission.storage]!.isPermanentlyDenied || statuses[Permission.manageExternalStorage]!.isPermanentlyDenied) {
      print("Ruxsat doimiy rad etilgan. Foydalanuvchini sozlamalarga yo‘naltiramiz.");
      await openAppSettings(); // Foydalanuvchini ilova sozlamalariga yo‘naltirish
    } else {
      print("Ruxsatlar rad etildi.");
    }
  }

  /// Load cookies before opening the WebView
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

  /// Print cookies after the page loads
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
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            useOnDownloadStart: true, // Enable the download callback
          ),
        ),
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
            await _printCookies();
            // Optional: Remove 'download' attributes from iframes via JS
            await _webViewController.evaluateJavascript(source: """
              document.querySelectorAll('iframe').forEach(iframe => {
                iframe.removeAttribute('download');
              });
            """);
          }
        },
        onDownloadStartRequest: (controller, request) async {
          print("Download requested: ${request.url}");
          // If it's a PDF (likely auto-triggered from an iframe), skip automatic download
          if (request.mimeType == "application/pdf" && request.contentDisposition != null && request.contentDisposition!.contains("inline")) {
            print("Detected inline PDF (auto-triggered). Skipping automatic download.");
            return;
          }

          await _downloadFile(request.url.toString());
        },
      ),
    );
  }

  /// Download file while ensuring storage permissions and saving into a dedicated folder
  Future<void> _downloadFile(String url) async {
    try {
      print("Starting download for: $url");

      // Ensure storage permission is granted.
      if (!await Permission.storage.isGranted) {
        print("Storage permission not granted, requesting...");
        await requestStoragePermission();
        if (!await Permission.storage.isGranted) {
          print("Permission still denied. Aborting download.");
          return;
        }
      }

      String? savePath = (await getExternalStorageDirectory())?.path;
      if (savePath == null) {
        print("Failed to get storage directory.");
        return;
      }


      try {
        // Retrieve cookies from the current session for the download URL.
        List<Cookie> cookies = await _cookieManager.getCookies(url: WebUri(url));
        String cookieHeader =
        cookies.map((cookie) => "${cookie.name}=${cookie.value}").join("; ");

        await FlutterDownloader.enqueue(
          url: url,
          savedDir: "/storage/emulated/0/Download",
          headers: {"cookie": cookieHeader},
          showNotification: true,
          openFileFromNotification: true,
          saveInPublicStorage: true,

        );

        print("Download enqueued successfully.");
      } catch (e) {
        print("Error while enqueuing the download: $e");
      }
    } catch (e) {
      print("Unexpected error occurred: $e");
    }
  }


}
