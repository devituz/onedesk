import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FileDownloadScreen(),
    );
  }
}

class FileDownloadScreen extends StatefulWidget {
  @override
  _FileDownloadScreenState createState() => _FileDownloadScreenState();
}

class _FileDownloadScreenState extends State<FileDownloadScreen> {
  bool _isDownloading = false;
  String _statusMessage = "Fayl yuklanmagan";

  /// 📥 **Faylni yuklab olish funksiyasi**
  Future<void> _downloadFile() async {
    setState(() {
      _isDownloading = true;
      _statusMessage = "Fayl yuklanmoqda...";
    });

    final String url =
        "https://onedesk.newuu.uz/en/cabinet/download-file?data=Y29udHJhY3QvMTczMTU4NTA2NS5wZGZ8MTc0MjI4MTk5Ng%3D%3D&hash=7274b53beeb68b94a71612941d177ca83d0b640ffe8e6fe4e917292b9df85905";

    // Cookie-larni to‘g‘ri formatda yaratamiz
    final String cookieHeader =
        "_language=a1e871a489161fa212e8c9148e0c6e71a5425cf241784f4c766821da3c19af5ba%3A2%3A%7Bi%3A0%3Bs%3A9%3A%22_language%22%3Bi%3A1%3Bs%3A2%3A%22en%22%3B%7D; "
        "_identity-frontend=6adaacaa1caa60a1689a137bf26dadbcbec5b0ae959627503d8d4e77244c1217a%3A2%3A%7Bi%3A0%3Bs%3A18%3A%22_identity-frontend%22%3Bi%3A1%3Bs%3A15%3A%22%5B220%2C%22%22%2C172800%5D%22%3B%7D; "
        "_csrf-frontend=895fda6ddc170d76b5a904c872b9209096e56552593d7a5bd5e17071433b82cca%3A2%3A%7Bi%3A0%3Bs%3A14%3A%22_csrf-frontend%22%3Bi%3A1%3Bs%3A32%3A%22g251R8LFmRfa40HjqqjFbRu6dOMuv6Yo%22%3B%7D; "
        "advanced-frontend=09a27787a24fe2a53bce90e414962c01";

    try {
      print("📡 HTTP so‘rov yuborilmoqda: $url");
      print("📝 Cookie-lar: $cookieHeader");

      var response = await http.get(
        Uri.parse(url),
        headers: {
          "Cookie": cookieHeader,
          "X-CSRF-Token": "g251R8LFmRfa40HjqqjFbRu6dOMuv6Yo", // CSRF token ham kerak
          "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
          "Referer": "https://onedesk.newuu.uz/en/cabinet/",
          "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
        },
      );

      print("🔹 HTTP Status Code: ${response.statusCode}");
      print("📋 HTTP Header'lar: ${response.headers}");
      print("📃 Response body uzunligi: ${response.bodyBytes.length} bayt");

      if (response.statusCode == 200) {
        String fileName = "downloaded_file.pdf"; // Default nom
        String? contentDisp = response.headers["content-disposition"];

        if (contentDisp != null) {
          RegExp regex = RegExp(r'filename\*?=(?:UTF-8\'')?([^";]+)');
          Match? match = regex.firstMatch(contentDisp);
          if (match != null) {
            fileName = Uri.decodeComponent(match.group(1)!);
          }
        }

        Directory dir = await getApplicationDocumentsDirectory();
        File file = File("${dir.path}/$fileName");

        await file.writeAsBytes(response.bodyBytes);
        print("✅ Fayl muvaffaqiyatli yuklandi: ${file.path}");

        setState(() {
          _statusMessage = "✅ Fayl yuklandi: ${file.path}";
        });
      } else {
        print("❌ Xatolik: ${response.statusCode}");
        print("📃 Xato ma’lumotlari: ${response.body}");

        setState(() {
          _statusMessage = "❌ Xatolik: ${response.statusCode}\n${response.body}";
        });
      }
    } catch (e) {
      print("❌ Xatolik sodir bo‘ldi: $e");

      setState(() {
        _statusMessage = "❌ Xatolik: $e";
      });
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fayl yuklash")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isDownloading ? null : _downloadFile,
              child: _isDownloading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("📥 Faylni yuklash"),
            ),
            SizedBox(height: 20),
            Text(_statusMessage, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
