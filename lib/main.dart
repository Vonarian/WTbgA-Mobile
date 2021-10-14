import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:wtbgamobile/screens/image_state.dart';
import 'package:wtbgamobile/screens/loading.dart';
import 'package:wtbgamobile/screens/splash.dart';

import 'screens/home.dart';

String icon = 'assets/app_icon.ico';
Future<void> main() async {
  const loading = '/loading';
  const home = '/home';
  const splash = '/splash';
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      'resource://drawable/logo',
      [
        NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Colors.transparent,
            ledColor: Colors.white)
      ]);
  runApp(MaterialApp(
    theme: ThemeData(
      brightness: Brightness.dark,
    ),
    darkTheme: ThemeData(
      brightness: Brightness.dark,
    ),
    themeMode: ThemeMode.dark,
    debugShowCheckedModeBanner: false,
    initialRoute: splash,
    routes: {
      splash: (context) => const Splash(),
      loading: (context) => const Loading(),
      home: (context) => const Home(),
      '/background': (context) => const ImageState(),
    },
  ));
}
