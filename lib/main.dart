import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'Home.dart';
import 'constants/validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl: true // option: set to false to disable working with http links (default: false)
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeNotifier()),
      ],
      child: MyApp(),
    ),
  );
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Connectivity _connectivity = Connectivity();
  ValueNotifier<bool> isOnline = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
      isOnline.value = !result.contains(ConnectivityResult.none);
    });
  }




  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      themeMode: themeNotifier.themeMode,
      theme: ThemeData.light().copyWith(
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Color(
            0xFF04041D)),
        textTheme: const TextTheme(bodyLarge: TextStyle(color: Color(0xFF04041D))),
      ),
      darkTheme: ThemeData.dark().copyWith(
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF04041D), foregroundColor: Colors.white),
        textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.white)),
      ),

      home: ValueListenableBuilder<bool>(
        valueListenable: isOnline,
        builder: (context, online, child) {
          return online ? CheckFirebasePage() : OfflinePage();
        },
      ),

    );
  }
}



class OfflinePage extends StatefulWidget {
  @override
  _OfflinePageState createState() => _OfflinePageState();
}

class _OfflinePageState extends State<OfflinePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(5),
        child: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double iconSize = constraints.maxWidth * 0.3;
          double textSize = constraints.maxWidth * 0.07;
          double subTextSize = constraints.maxWidth * 0.045;

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Wi-Fi icon
                  Icon(
                    color: Theme.of(context).textTheme.bodyLarge?.color,

                    Icons.wifi_off,
                    size: iconSize,
                  )
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .scale(begin: Offset(1, 1), end: Offset(1.2, 1.2), duration: 800.ms)
                      .fade(begin: 0.5, end: 1, duration: 800.ms),

                  SizedBox(height: 20),

                  // Texts
                  Text(
                    'No Internet',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: textSize,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,

                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Please check your connection and try again!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),

                  SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void updateTheme(Brightness brightness) {
    _themeMode =
    brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    _updateSystemUI(brightness);
    notifyListeners();
  }

  void _updateSystemUI(Brightness brightness) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: brightness == Brightness.dark
            ? Color(0xFF04041D)
            : Colors.white,
        statusBarIconBrightness: brightness == Brightness.dark ? Brightness
            .light : Brightness.dark,
        systemNavigationBarColor: brightness == Brightness.dark ? Color(
            0xFF04041D) : Colors.white,
        systemNavigationBarIconBrightness: brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }
}

