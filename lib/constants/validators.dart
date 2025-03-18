import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:onedesk/constants/sizedbox.dart';
import 'package:onedesk/constants/strings.dart';

import '../Home.dart';
import 'colors.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email required';
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }


  static String TruncateText(String text) {
    if (text.length > 30) {
      return text.substring(0, 30) + '...';
    }
    return text;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number required';
    }
    final phoneRegExp = RegExp(r'^\+?(\d{1,3})?\s?(\d{10})$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? validateRequiredField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static bool isFormValid(List<String?> errors) {
    return errors.every((error) => error == null);
  }
}

class CheckFirebasePage extends StatefulWidget {
  @override
  _CheckFirebasePageState createState() => _CheckFirebasePageState();
}

class _CheckFirebasePageState extends State<CheckFirebasePage> {

  final String url = 'https://raw.githubusercontent.com/devituz/telegram_log_sender/refs/heads/master/firbase.json';
  Future<bool> checkFirebaseStatus() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        final firebaseQValue = data.firstWhere((element) =>
            element.containsKey('firebase_od'))['firebase_od'];
        return firebaseQValue == true;
      } else {
        return false;
      }
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;

    bool isDarkMode = brightness == Brightness.dark;


    return FutureBuilder<bool>(
      future: checkFirebaseStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
              backgroundColor: isDarkMode ? Colors.black : Colors.white, // 📌 AppBar rangi

              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(5), // 🔹 AppBar balandligini 40px ga tushirish
                child: AppBar(
                  backgroundColor: Theme.of(context).appBarTheme.backgroundColor, // 📌 AppBar rangi
                  foregroundColor: Theme.of(context).appBarTheme.foregroundColor, // 📌 AppBar ichki matn rangi            elevation: 0,
                ),
              ),
              body: Center()
          );
        } else if (snapshot.hasError) {
          return  Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(5), // 🔹 AppBar balandligini 40px ga tushirish
                child: AppBar(
                  backgroundColor: Theme.of(context).appBarTheme.backgroundColor, // 📌 AppBar rangi
                  foregroundColor: Theme.of(context).appBarTheme.foregroundColor, // 📌 AppBar ichki matn rangi            elevation: 0,
                ),
              ),
              body: Center()
          );
        } else if (snapshot.hasData && snapshot.data == true) {
          return MyWebView();
        } else {
          return ErrorScreen();
        }
      },
    );
  }
}



class ErrorScreen extends StatefulWidget {
  const ErrorScreen({super.key});

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${AppStrings.erorrSahifa_topilmadi}",
          style: TextStyle(color: AppStyles.qora, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
              image: AssetImage('lib/public/assets/404.png'),
              width: 300,
            ),
            sizedBoxHeight25,
            const SizedBox(
              width: 300,
              child: Text(
                AppStrings.erorr_404_message_body,
                style: TextStyle(
                    color: AppStyles.qora, fontWeight: FontWeight.normal),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

