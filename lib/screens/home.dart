import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:blinking_text/blinking_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wtbgamobile/chat_data/received_chat.dart';
import 'package:wtbgamobile/data_receiver/serverdata.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  saveFileFromBase64String(String path, String base64String) =>
      File(path).writeAsBytes(base64Decode(base64String));

  Future<void> updateData() async {
    if (userInputInHome == null || userInputInHome == '') return;
    // final WifiInfo _wifiInfo = WifiInfo();
    // String? wifiInfo;
    // wifiInfo = await _wifiInfo.getWifiIP();
    // print(wifiInfo);
    if (!mounted) return;
    ServerData internalServerData =
        await ServerData.getData(userInputInHome ?? '');
    setState(() {
      serverData = internalServerData;
      serverMsg = serverData.damageMsg;
      ias = serverData.ias;
      tas = serverData.tas;
      critAoa = serverData.critAoa;
      gear = serverData.gear;
      minFuel = serverData.minFuel;
      maxFuel = serverData.maxFuel;
      oilTemp = serverData.oil;
      waterTemp = serverData.water;
      altitude = serverData.altitude;
      aoa = serverData.aoa;
      engineTemp = serverData.engineTemp;
      throttle = serverData.throttle;
      vehicleName = serverData.vehicleName;
      climb = serverData.climb;
      chatId1 = serverData.chatId1;
      chatId2 = serverData.chatId2;
      chatMessage1 = serverData.chatMsg1;
      chatMessage2 = serverData.chatMsg2;
      chatMode1 = serverData.chatMode1;
      chatMode2 = serverData.chatMode2;
      chatSender1 = serverData.chatSender1;
      chatSender2 = serverData.chatSender2;
      chatEnemy1 = serverData.chatEnemy1;
      chatEnemy2 = serverData.chatEnemy2;
      // if (chatList.isNotEmpty) {
      //   chatList.removeAt(0);
      //   if (chatList.length > 1) {
      //     chatList.removeLast();
      //   }
      // }
      // if (chatMessageFirst != 'No Data') {
      //   chatList.add(chatMessageFirst);
      //   chatList.add(chatMessageSecond);
      // }
      idData.value = serverData.damageId;
    });

    // print(serverMsg);
  }

  // static Route<int> dialogBuilder(BuildContext context) {
  //   return DialogRoute(
  //       context: context,
  //       builder: (BuildContext context) => AlertDialog(
  //             content: const Text('Allow notification access?'),
  //             title: const Text('Notifications permission request '),
  //             actions: [
  //               ElevatedButton(
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                   },
  //                   child: const Text('Cancel')),
  //               ElevatedButton(
  //                   onPressed: () {
  //                     AwesomeNotifications()
  //                         .isNotificationAllowed()
  //                         .then((isAllowed) {
  //                       if (!isAllowed) {
  //                         // Insert here your friendly dialog box before call the request method
  //                         // This is very important to not harm the user experience
  //                         AwesomeNotifications()
  //                             .requestPermissionToSendNotifications();
  //                       }
  //                     });
  //                     Navigator.of(context).pop();
  //                   },
  //                   child: const Text('Allow'))
  //             ],
  //           ));
  // }

  Future<void> notifications() async {
    if (isDamageIdNew && serverData.damageMsg == 'Engine overheated') {
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              icon: 'resource://drawable/logo',
              id: 1,
              channelKey: 'basic_channel',
              title: 'Engine Overheated!',
              body: 'Engine is overheating'));
      isDamageIdNew = false;
    }
    if (isDamageIdNew && serverMsg == 'Oil overheated') {
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              icon: 'resource://drawable/logo',
              id: 2,
              channelKey: 'basic_channel',
              title: 'Oil Overheated!',
              body: 'Oil is overheating'));
      isDamageIdNew = false;
    }
    if (isDamageIdNew && serverMsg == "Engine died: no fuel") {
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              icon: 'resource://drawable/logo',
              id: 2,
              channelKey: 'basic_channel',
              title: 'Engine died!',
              body: 'Engine ran out of fuel and died.'));
      isDamageIdNew = false;
    }
    if (isDamageIdNew && serverMsg == "Engine died: overheating") {
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              icon: 'resource://drawable/logo',
              id: 2,
              channelKey: 'basic_channel',
              title: 'Engine died!',
              body: 'Engine died due to overheating'));
      isDamageIdNew = false;
    }
    if (isDamageIdNew && serverMsg == "Engine died: propeller broken") {
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              icon: 'resource://drawable/logo',
              id: 2,
              channelKey: 'basic_channel',
              title: 'Engine died!',
              body: 'Engine died due to propeller damage'));
      isDamageIdNew = false;
    }
  }

  Future<void> loadInput() async {
    await _prefs.then((SharedPreferences prefs) async {
      userInputInHome = (prefs.getString('userInputInHome') ?? '');
    });
    await _prefs.then((SharedPreferences prefs) async {
      lastId = (prefs.getInt('lastId') ?? 0);
    });
    if (userInputInHome != '' && userInputInHome != null) return;
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      userInputInHome = ModalRoute.of(context)?.settings.arguments;
    });
  }

  @override
  void initState() {
    updateData();
    chatSettingsManager();
    loadInput();
    idData.addListener(() async {
      if (lastId != idData.value) {
        isDamageIdNew = true;
      }
      await notifications();
      SharedPreferences prefs = await _prefs;
      lastId = (prefs.getInt('lastId') ?? 0);
      lastId = idData.value;
      prefs.setInt('lastId', lastId!);
    });
    isDamageIdNew = false;
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      updateData();
      stallDetector();
      chatSettingsManager();
    });
  }

  @override
  void dispose() {
    idData.removeListener(() => notifications());
    super.dispose();
  }

  // Future<void> setImage() async {
  //   Directory? appDocDirectory = await getExternalStorageDirectory();
  //   Directory(appDocDirectory!.path + '/' + 'dir').create(recursive: true);
  //   if (imageData != 'null') {
  //     dynamic image = await saveFileFromBase64String(
  //         '${appDocDirectory.path}.png', imageData);
  //
  //     setState(() {
  //       imageOut = image;
  //       imageNotNull = true;
  //     });
  //   } else {
  //     imageNotNull = false;
  //   }
  // }

  void stallDetector() {
    if (aoa != null && critAoa != null && climb != null && aoa! >= -critAoa!) {
      if (!mounted) return;
      setState(() {
        critAoaBool = true;
      });
    }
  }

  Widget waterText() {
    return Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(10, 123, 10, 0.403921568627451),
                Color.fromRGBO(0, 50, 158, 0.4196078431372549),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(20.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.07),
                spreadRadius: 4,
                blurRadius: 7,
                offset: const Offset(0, 3),
              )
            ]),
        child: waterTemp != null
            ? Text(
                'Water Temp = $waterTemp degrees',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )
            : const Text(
                'No Data for Water temperature',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ));
  }

  Widget throttleText() {
    return Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(10, 123, 10, 0.403921568627451),
                Color.fromRGBO(0, 50, 158, 0.4196078431372549),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(20.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.07),
                spreadRadius: 4,
                blurRadius: 7,
                offset: const Offset(0, 3),
              )
            ]),
        child: throttle != null
            ? Text(
                'Throttle = ${(throttle! * 100).toStringAsFixed(0)}%',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )
            : const Text(
                'No Data for throttle',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ));
  }

  Widget iasText() {
    return Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(10, 123, 10, 0.403921568627451),
                Color.fromRGBO(0, 50, 158, 0.4196078431372549),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(20.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.07),
                spreadRadius: 4,
                blurRadius: 7,
                offset: const Offset(0, 3),
              )
            ]),
        child: ias != null
            ? Text(
                'IAS = $ias km/h',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )
            : const Text(
                'No Data for IAS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ));
  }

  Widget tasText() {
    return Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(10, 123, 10, 0.403921568627451),
                Color.fromRGBO(0, 50, 158, 0.4196078431372549),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(20.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.07),
                spreadRadius: 4,
                blurRadius: 7,
                offset: const Offset(0, 3),
              )
            ]),
        child: tas != null
            ? Text(
                'TAS = $tas km/h',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )
            : const Text(
                'No Data for TAS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ));
  }

  Widget climbText() {
    return Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(10, 123, 10, 0.403921568627451),
                Color.fromRGBO(0, 50, 158, 0.4196078431372549),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(20.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.07),
                spreadRadius: 4,
                blurRadius: 7,
                offset: const Offset(0, 3),
              )
            ]),
        child: aoa != null &&
                critAoa != null &&
                climb != null &&
                !(aoa! >= -critAoa!)
            ? Text(
                'Climb rate = $climb m/s',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )
            : critAoaBool
                ? BlinkText('Climb rate = $climb m/s (Stalling!)',
                    duration: const Duration(milliseconds: 200),
                    endColor: Colors.red,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black))
                : const Text(
                    'No Data for climb rate',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ));
  }

  static Route<String> dialogBuilderForIP(BuildContext context) {
    TextEditingController userInput = TextEditingController();
    return DialogRoute(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(const SnackBar(
                      content: Text('Server IP Address has been updated')));
                Navigator.of(context).pop((userInput.text));
              },
              child: const Text('Set IP')),
        ],
        title: const Text(
            'Enter server IP Address (Shown in sidebar menu of desktop WTbgA)'),
        content: TextField(
          onChanged: (value) {},
          controller: userInput,
          decoration: const InputDecoration(hintText: "192.168.X.Y"),
        ),
      ),
    );
  }

  Widget fuelIndicator() {
    double? fuelPercent;
    if (minFuel != null && maxFuel != null) {
      fuelPercent = (minFuel! / maxFuel!) * 100;
    }
    return Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(10, 123, 10, 0.403921568627451),
                Color.fromRGBO(0, 50, 158, 0.4196078431372549),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(20.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.07),
                spreadRadius: 4,
                blurRadius: 7,
                offset: const Offset(0, 3),
              )
            ]),
        child: minFuel != null && fuelPercent! >= 15.00
            ? Text(
                'Remaining Fuel = ${fuelPercent.toStringAsFixed(0)}%',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )
            : minFuel != null &&
                    fuelPercent! < 15.00 &&
                    (altitude != 32 && minFuel != 0)
                ? BlinkText(
                    'Remaining Fuel = ${fuelPercent.toStringAsFixed(0)}%',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                    endColor: Colors.red,
                  )
                : const Text('No Data.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)));
  }

  Widget drawerBuilder() {
    return Drawer(
      child: Container(
        color: Colors.black45,
        child: ListView(
          children: [
            const DrawerHeader(
              curve: Curves.bounceIn,
              duration: Duration(seconds: 12),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Icon(
                Icons.settings,
                size: 100,
              ),
            ),
            Container(
                color: Colors.green,
                child: RichText(
                  text: TextSpan(
                    text: 'Server running on: ',
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                          text: '$userInputInHome',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                )),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              onPressed: () async {
                final SharedPreferences prefs = await _prefs;
                userInputInHome = await Navigator.of(context)
                    .push(dialogBuilderForIP(context));
                String _userInputInHome =
                    (prefs.getString('userInputInHome') ?? '');
                setState(() {
                  _userInputInHome = userInputInHome!;
                });
                prefs.setString("userInputInHome", _userInputInHome);
              },
              child: const Text('Update server IP'),
            ),
            ReceivedMessageScreen(
              chatSender: chatSender2,
              message: '$chatPrefix2 $chatMessage2',
              style: TextStyle(color: chatColor2),
            ),
            ReceivedMessageScreen(
              chatSender: chatSender1,
              message: '$chatPrefix1 $chatMessage1',
              style: TextStyle(color: chatColor1),
            ),
          ],
        ),
      ),
    );
  }

  chatSettingsManager() {
    if (!mounted) return;
    setState(() {
      if (chatMode1 == 'All') {
        chatPrefix1 = '[ALL]';
      }
      if (chatMode1 == 'Team') {
        chatPrefix1 = '[Team]';
      }
      if (chatMode1 == 'Squad') {
        chatPrefix1 = '[Squad]';
      }
      if (chatMode1 == null) {
        chatPrefix1 = null;
      }
      if (chatSender1 == null) {
        chatSender1 == emptyString;
      }
      if (chatEnemy1 == true) {
        chatColor1 = Colors.red;
      } else {
        chatColor1 = Colors.lightBlueAccent;
      }
    });
    setState(() {
      if (chatMode2 == 'All') {
        chatPrefix2 = '[ALL]';
      }
      if (chatMode2 == 'Team') {
        chatPrefix2 = '[Team]';
      }
      if (chatMode2 == 'Squad') {
        chatPrefix2 = '[Squad]';
      }
      if (chatMode2 == null) {
        chatPrefix2 = null;
      }
      if (chatSender2 == null) {
        chatSender2 == emptyString;
      }
      if (chatEnemy2 == true) {
        chatColor2 = Colors.red;
      } else {
        chatColor2 = Colors.lightBlueAccent;
      }
    });
  }

  bool? isAllowed;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  dynamic userInputInHome;
  int? ias;
  int? tas;
  double? climb;
  double? critAoa;
  double? aoa;
  double? throttle;
  double? engineTemp;
  int? oilTemp;
  dynamic waterTemp;
  int? altitude;
  int? minFuel;
  int? maxFuel;
  int? gear;
  int? lastId;
  String? emptyString = 'No Data';
  String? serverMsg;
  String? vehicleName;
  String? chatMessage1;
  String? chatMessage2;
  bool? chatEnemy1;
  bool? chatEnemy2;
  int? chatId1;
  int? chatId2;
  String? chatSender1;
  String? chatSender2;
  String? chatMode1;
  String? chatMode2;
  String? chatPrefix1;
  String? chatPrefix2;
  Color? chatColor1;
  Color? chatColor2;
  dynamic imageData;
  dynamic imageOut;
  // String? wifiIP;
  // String icon = 'assets/app_icon.ico';
  int? idDataSaver;
  ValueNotifier<int?> idData = ValueNotifier(null);
  bool isDamageIdNew = false;
  bool critAoaBool = false;
  bool imageNotNull = false;
  dynamic serverData;
  @override
  Widget build(BuildContext context) {
    updateData();
    return SafeArea(
      child: Stack(children: [
        Scaffold(
          drawer: Builder(builder: (context) {
            return drawerBuilder();
          }),
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () async {
                  Navigator.pushReplacementNamed(context, '/background',
                      arguments: userInputInHome);
                },
                icon: const Icon(Icons.image),
              )
            ],
            backgroundColor: Colors.black45,
            centerTitle: true,
            title: vehicleName != 'NULL' && vehicleName != null
                ? Text(
                    'You are flying $vehicleName',
                    style: const TextStyle(fontSize: 18),
                  )
                : const Text('You are not flying'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                throttleText(),
                iasText(),
                tasText(),
                fuelIndicator(),
                waterText(),
                climbText(),
              ],
            ),
          ),
        )
      ]),
    );
  }
}
