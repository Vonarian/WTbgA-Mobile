import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wtbgamobile/screens/image_state.dart';
import 'package:wtbgamobile/screens/loading.dart';

import 'screens/home.dart';

StateProvider<String> stateProvider = StateProvider((ref) => 'home');
String icon = 'assets/app_icon.ico';
// final sharedPrefProvider = Provider<SharedPreferences>((_)=> throw UnimplementedError());
// Future<void> main()async{
//   final prefs = await SharedPreferences.getInstnace();
//   runApp(ProviderScope(overrides: [prefs.overrideWithValue(prefs)], child: your root widget));
// }
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const loading = '/loading';
  const home = '/home';
  const image = '/image';
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      'resource://drawable/logo',
      [
        NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Colors.transparent,
            ledColor: Colors.greenAccent)
      ]);
  runApp(ProviderScope(
    child: MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      initialRoute: loading,
      routes: {
        // splash: (context) => const Splash(),
        loading: (context) => const Loading(),
        home: (context) => const Home(),
        image: (context) => const ImageState(),
      },
    ),
  ));
}
