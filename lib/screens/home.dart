import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:blinking_text/blinking_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:wtbgamobile/chat_data/received_chat.dart';

import '../main.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  saveFileFromBase64String(String path, String base64String) =>
      File(path).writeAsBytes(base64Decode(base64String));

  // Future<void> updateData() async {
  //   await loadInput();
  //   var state = ref.read(stateProvider);
  //   // if (state.state != 'home') return;
  //   var waterTemp = ref.read(waterTempProvider);
  //   var oilTemp = ref.read(oilTempProvider);
  //   var throttle = ref.read(throttleProvider);
  //   var vehicleName = ref.read(vehicleNameProvider);
  //   // if (ip.state == null || ip.state == '') return;
  //   Map<String, dynamic> internalServerData =
  //       getData(ip.state, state.state);
  //   Timer.periodic(Duration(seconds: 1), (timer) {
  //     print('$internalServerData is the value');
  //
  //     oilTemp.state = internalServerData['oil'];
  //     waterTemp.state = internalServerData['water'];
  //     throttle.state = double.tryParse(internalServerData['throttle']);
  //     vehicleName.state = internalServerData['vehicleName'];
  //     serverMsg = internalServerData['damageMsg'];
  //     ias = internalServerData['ias'];
  //     tas = internalServerData['tas'];
  //     critAoa = internalServerData['critAoa'];
  //     gear = internalServerData['gear'];
  //     minFuel = internalServerData['minFuel'];
  //     maxFuel = internalServerData['maxFuel'];
  //     altitude = internalServerData['altitude'];
  //     aoa = internalServerData['aoa'];
  //     engineTemp = internalServerData['engineTemp'];
  //     climb = internalServerData['climb'];
  //     chatId1 = internalServerData['chatId1'];
  //     chatId2 = internalServerData['chatId2'];
  //     chatMessage1 = internalServerData['chat1'];
  //     chatMessage2 = internalServerData['chat2'];
  //     chatMode1 = internalServerData['chatMode1'];
  //     chatMode2 = internalServerData['chatMode2'];
  //     chatSender1 = internalServerData['chatSender1'];
  //     chatSender2 = internalServerData['chatSender2'];
  //     chatEnemy1 = internalServerData['chatEnemy1'];
  //     chatEnemy2 = internalServerData['chatEnemy2'];
  //     idData.value = internalServerData['damageId'];
  //   });
  // }

  Future<void> notifications() async {
    if (isDamageIdNew && serverMsg == 'Engine overheated') {
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
    if (isDamageIdNew && serverMsg == 'Engine died: no fuel') {
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              icon: 'resource://drawable/logo',
              id: 2,
              channelKey: 'basic_channel',
              title: 'Engine died!',
              body: 'Engine ran out of fuel and died.'));
      isDamageIdNew = false;
    }
    if (isDamageIdNew && serverMsg == 'Engine died: overheating') {
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              icon: 'resource://drawable/logo',
              id: 2,
              channelKey: 'basic_channel',
              title: 'Engine died!',
              body: 'Engine died due to overheating'));
      isDamageIdNew = false;
    }
    if (isDamageIdNew && serverMsg == 'Engine died: propeller broken') {
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

  Future<void> manageWakeLock() async {
    await Wakelock.disable();
    wakeLockStat = await Wakelock.enabled;
    print(wakeLockStat);
  }

  Future<void> loadInput() async {
    var userInputInHome = ref.read(userInputInHomeProvider.notifier);

    // WidgetsBinding.instance!.addPostFrameCallback((_) async {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    await _prefs.then((SharedPreferences prefs) async {
      userInputInHome.state =
          (prefs.getString('userInputInHome') ?? arguments['input']);
      homeStream = await WebSocketChannel.connect(
          Uri.parse('ws://${userInputInHome.state}:55200'));
    });
    await _prefs.then((SharedPreferences prefs) async {
      lastId = (prefs.getInt('lastId') ?? 0);
    });
    // });
    // if (userInputInHome == null || userInputInHome == arguments['input']) {
    //   print(userInputInHome);
    //   userInputInHome = arguments['input'];
    // }
  }

  @override
  void initState() {
    super.initState();
    checkTimer.start();
    Future.delayed(Duration.zero, () async {
      await loadInput();
      manageWakeLock();
    });
    Future.delayed(Duration(milliseconds: 500), () {
      showLoading = false;
    });
    var state = ref.read(stateProvider.notifier);

    state.state = 'home';
    phoneData = {
      'state': state.state,
      'WTbgA': true,
      'startStream': false,
    };
    chatSettingsManager();
    check.addListener(() {
      checkTimer.reset();
      once = 0;
      showLost = false;
    });
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    timer;
  }

  int once = 0;
  late Timer timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    print(checkTimer.elapsedMilliseconds);
    if (checkTimer.elapsedMilliseconds >= 3000 && once == 0) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
            duration: Duration(seconds: 10),
            action: SnackBarAction(
              onPressed: () {
                var userInputInHome =
                    ref.read(userInputInHomeProvider.notifier);
                Navigator.pushReplacementNamed(context, '/home',
                    arguments: {'input': userInputInHome.state});
              },
              label: 'Reconnect',
            ),
            content: BlinkText(
              'Connection lost, click on the button to restart',
              style: TextStyle(color: Colors.blue),
              endColor: Colors.red,
            )));
      once = 1;
      showLost = true;
    }
    stallDetector();
    chatSettingsManager();
    if (!mounted) return;
    setState(() {});
  });
  @override
  void dispose() {
    super.dispose();
    timer.cancel();

    idData.removeListener(() => notifications());
    homeStream!.sink.close();
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
      critAoaBool = true;
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
                'Water Temp = ${waterTemp} degrees',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )
            : const Text(
                'No Data for Water temperature',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ));
  }

  Widget throttleText() {
    var throttle = ref.watch(throttleProvider.notifier);
    // print(throttle.state);
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
        child: throttle.state != null
            ? Text(
                'Throttle = ${(throttle.state! * 100).toStringAsFixed(0)}%',
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

  // Widget tasText() {
  //   return Container(
  //       alignment: Alignment.center,
  //       width: MediaQuery.of(context).size.width,
  //       decoration: BoxDecoration(
  //           gradient: const LinearGradient(
  //             colors: [
  //               Color.fromRGBO(10, 123, 10, 0.403921568627451),
  //               Color.fromRGBO(0, 50, 158, 0.4196078431372549),
  //             ],
  //             begin: Alignment.centerLeft,
  //             end: Alignment.centerRight,
  //           ),
  //           borderRadius: const BorderRadius.all(
  //             Radius.circular(20.0),
  //           ),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.red.withOpacity(0.07),
  //               spreadRadius: 4,
  //               blurRadius: 7,
  //               offset: const Offset(0, 3),
  //             )
  //           ]),
  //       child: tas != null
  //           ? Text(
  //               'TAS = $tas km/h',
  //               style:
  //                   const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
  //             )
  //           : const Text(
  //               'No Data for TAS',
  //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
  //             ));
  // }

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
        child: climb != 0 &&
                aoa != null &&
                critAoa != null &&
                climb != null &&
                !(aoa! >= -critAoa!)
            ? Text(
                'Climb rate = $climb m/s',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )
            : climb != 0 && critAoaBool && altitude != null && altitude! > 200
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

  static Route<String> dialogBuilderForIP(
      BuildContext context, String? userInputInHome) {
    late TextEditingController userInput =
        TextEditingController(text: userInputInHome);
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
          decoration: const InputDecoration(hintText: '192.168.X.Y'),
        ),
      ),
    );
  }

  Widget altText() {
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
        child: altitude != null && altitude! >= 100
            ? Text(
                'Altitude = $altitude meters',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )
            : altitude != null && altitude! <= 100 && oilTemp != 15
                ? BlinkText(
                    'Altitude = $altitude meters (Too low!!)',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black),
                    endColor: Colors.red,
                  )
                : Text(
                    'No data for altitude',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ));
  }

  Widget oilText() {
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
        child: oilTemp != null
            ? Text(
                'Oil Temp = ${oilTemp} degrees',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )
            : Text(
                'No data for Oil Temp',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ));
  }

  Widget fuelIndicator() {
    Timer.periodic(Duration.zero, (timer) {
      if (minFuel != null && maxFuel != null) {
        fuelPercent = (minFuel! / maxFuel!) * 100;
      }
    });
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
                'Remaining Fuel = ${fuelPercent!.toStringAsFixed(0)}%',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )
            : minFuel != null &&
                    fuelPercent! < 15.00 &&
                    (altitude != 32 && minFuel != 0)
                ? BlinkText(
                    'Remaining Fuel = ${fuelPercent!.toStringAsFixed(0)}%',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                    endColor: Colors.red,
                  )
                : const Text('No Data for Fuel',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)));
  }

  Widget drawerBuilder() {
    var userInputInHome = ref.read(userInputInHomeProvider.notifier);
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
                          text: '${userInputInHome.state}',
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
                var userInputInHome =
                    ref.read(userInputInHomeProvider.notifier);
                final SharedPreferences prefs = await _prefs;
                userInputInHome.state = (await Navigator.of(context)
                    .push(dialogBuilderForIP(context, userInputInHome.state)))!;
                String _userInputInHome =
                    (prefs.getString('userInputInHome') ?? '');
                setState(() {
                  _userInputInHome = userInputInHome.state!;
                });
                prefs.setString('userInputInHome', _userInputInHome);
                homeStream = await WebSocketChannel.connect(
                    Uri.parse('ws://${userInputInHome.state}:55200'));
              },
              child: const Text('Update server IP'),
            ),
            ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      wakeLockStat ? Colors.blue : Colors.red),
                ),
                icon: wakeLockStat
                    ? Icon(Icons.wb_incandescent)
                    : Icon(Icons.wb_incandescent_outlined),
                onPressed: () async {
                  print(wakeLockStat);

                  if (!wakeLockStat)
                    await Wakelock.enable();
                  else
                    await Wakelock.disable();
                  wakeLockStat = !wakeLockStat;
                  print(wakeLockStat);
                },
                label: wakeLockStat
                    ? const Text('Screen timeout: Off')
                    : const Text('Screen timeout: On')),
            chatMessage1 != 'No Data'
                ? ReceivedMessageScreen(
                    chatSender: chatSender2,
                    message: '$chatPrefix2 $chatMessage2',
                    style: TextStyle(color: chatColor2),
                  )
                : Container(),
            chatMessage1 != 'No Data'
                ? ReceivedMessageScreen(
                    chatSender: chatSender1,
                    message: '$chatPrefix1 $chatMessage1',
                    style: TextStyle(color: chatColor1),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  // Future<void> giveIps() async {
  //   for (var interface in await NetworkInterface.list()) {
  //     for (var addr in interface.addresses) {
  //       phoneIP = addr.address;
  //     }
  //   }
  // }

  chatSettingsManager() {
    if (!mounted) return;
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
      chatSender1 = emptyString;
    }
    if (chatEnemy1 == true) {
      chatColor1 = Colors.red;
    } else {
      chatColor1 = Colors.lightBlueAccent;
    }
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
      chatSender2 = emptyString;
    }
    if (chatEnemy2 == true) {
      chatColor2 = Colors.red;
    } else {
      chatColor2 = Colors.lightBlueAccent;
    }
  }

  PreferredSizeWidget appBar(BuildContext context) {
    return AppBar(
      actions: [
        IconButton(
          tooltip: 'Navigate to Stream screen',
          onPressed: () async {
            var state = ref.read(stateProvider.notifier);
            var userInputInHome = ref.read(userInputInHomeProvider.notifier);

            state.state = 'image';
            phoneData = {'state': state, 'WTbgA': true, 'startStream': true};
            homeStream!.sink.add(jsonEncode(phoneData));
            Navigator.pushReplacementNamed(context, '/image', arguments: {
              'state': state.state,
              'input': userInputInHome.state,
              // 'server': server
            });
          },
          icon: const Icon(Icons.image),
        ),
      ],
      backgroundColor: Colors.black45,
      centerTitle: true,
      title: vehicleName != 'NULL' && vehicleName != null
          ? Text(
              'You are flying ${vehicleName}',
              style: const TextStyle(fontSize: 18),
            )
          : Text('You are not flying'),
    );
  }

  StateProvider<String?> userInputInHomeProvider =
      StateProvider<String?>((ref) {
    return null;
  });
  // String? homeState;
  // String phoneIP = '';
  // bool? isAllowed;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  int? ias;
  int? tas;
  double? climb;
  double? critAoa;
  double? aoa;
  double? engineTemp;
  double? fuelPercent = 000;
  StateProvider<double?> throttleProvider = StateProvider<double?>((ref) {
    return null;
  });

  int? altitude;
  int? minFuel;
  int? maxFuel;
  int? gear;
  int? lastId;
  String? emptyString = 'No Data';
  String? serverMsg;
  String? chatMessage1;
  String? chatMessage2;
  bool? chatEnemy1;
  bool? chatEnemy2;
  bool wakeLockStat = true;
  int? chatId1;
  int? chatId2;
  int? waterTemp;
  int? oilTemp;
  String? vehicleName;
  String? chatSender1;
  String? chatSender2;
  String? chatMode1;
  String? chatMode2;
  String? chatPrefix1;
  String? chatPrefix2;
  Color? chatColor1;
  Color? chatColor2;
  // String? wifiIP;
  // String icon = 'assets/app_icon.ico';
  int? idDataSaver;
  ValueNotifier<int?> idData = ValueNotifier(null);
  ValueNotifier<int?> check = ValueNotifier(0);
  bool isDamageIdNew = false;
  bool critAoaBool = false;
  bool imageNotNull = false;
  bool showLoading = true;
  bool showLost = false;
  WebSocketChannel? homeStream;
  Stopwatch checkTimer = Stopwatch();

  late Map<String, dynamic>? phoneData = {};
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Builder(builder: (context) {
          return drawerBuilder();
        }),
        backgroundColor: Colors.black,
        appBar: appBar(context),
        body: GestureDetector(
          onDoubleTap: () {
            var userInputInHome = ref.read(userInputInHomeProvider.notifier);
            Navigator.pushReplacementNamed(context, '/home',
                arguments: {'input': userInputInHome.state});
          },
          child: Center(
            child: !showLoading && !showLost
                ? StreamBuilder(
                    stream: homeStream!.stream,
                    builder: (BuildContext context, snapshot) {
                      homeStream!.sink.add(jsonEncode(phoneData));
                      if (snapshot.hasData) {
                        var throttle = ref.watch(throttleProvider.notifier);
                        Map<String, dynamic> internalServerData =
                            jsonDecode(snapshot.data as String);
                        WidgetsBinding.instance!.addPostFrameCallback((_) {
                          throttle.state = internalServerData['throttle'];
                        });
                        oilTemp = internalServerData['oil'];
                        waterTemp = internalServerData['water'];
                        vehicleName = internalServerData['vehicleName'];
                        serverMsg = internalServerData['damageMsg'];
                        ias = internalServerData['ias'];
                        tas = internalServerData['tas'];
                        critAoa = internalServerData['critAoa'];
                        gear = internalServerData['gear'];
                        minFuel = internalServerData['minFuel'];
                        maxFuel = internalServerData['maxFuel'];
                        altitude = internalServerData['altitude'];
                        aoa = internalServerData['aoa'];
                        engineTemp = internalServerData['engineTemp'];
                        climb = internalServerData['climb'];
                        chatId1 = internalServerData['chatId1'];
                        chatId2 = internalServerData['chatId2'];
                        chatMessage1 = internalServerData['chat1'];
                        chatMessage2 = internalServerData['chat2'];
                        chatMode1 = internalServerData['chatMode1'];
                        chatMode2 = internalServerData['chatMode2'];
                        chatSender1 = internalServerData['chatSender1'];
                        chatSender2 = internalServerData['chatSender2'];
                        chatEnemy1 = internalServerData['chatEnemy1'];
                        chatEnemy2 = internalServerData['chatEnemy2'];
                        idData.value = internalServerData['damageId'];
                        check.value = internalServerData['check'];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            throttleText(),
                            iasText(),
                            fuelIndicator(),
                            waterText(),
                            oilText(),
                            altText(),
                            climbText(),
                          ],
                        );
                      }
                      if (snapshot.hasError) {
                        print(snapshot.error);
                        return Stack(children: [
                          Center(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                              alignment: Alignment.center,
                              child: BlinkText(
                                snapshot.error.toString().contains('timed out')
                                    ? 'Connection request timed out'
                                    : 'Unknown error',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 15),
                                textAlign: TextAlign.center,
                                endColor: Colors.purple,
                              ),
                            ),
                          ),
                        ]);
                      } else {
                        print(snapshot.connectionState);
                        // homeStream = WebSocketChannel.connect(
                        //     Uri.parse('ws://${userInputInHome}:55200'));
                        return Stack(children: [
                          Center(
                            child: BlinkText(
                              snapshot.connectionState.toString() ==
                                      'ConnectionState.waiting'
                                  ? 'Awaiting connection'
                                  : snapshot.connectionState.toString(),
                              style: TextStyle(color: Colors.red, fontSize: 15),
                              textAlign: TextAlign.center,
                              endColor: Colors.purple,
                            ),
                          ),
                          Center(
                            child: Container(
                              height: 200,
                              width: 200,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.red,
                              ),
                            ),
                          ),
                        ]);
                      }
                    },
                  )
                : showLost
                    ? Stack(children: [
                        Center(
                          child: BlinkText(
                            'No connection\nDouble tap to reconnect',
                            style: TextStyle(color: Colors.red, fontSize: 15),
                            textAlign: TextAlign.center,
                            endColor: Colors.purple,
                          ),
                        ),
                        Center(
                          child: Container(
                            height: 200,
                            width: 200,
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ),
                      ])
                    : Stack(children: [
                        Center(
                          child: BlinkText(
                            'Loading...',
                            style: TextStyle(color: Colors.red, fontSize: 15),
                            textAlign: TextAlign.center,
                            endColor: Colors.purple,
                          ),
                        ),
                        Center(
                          child: Container(
                            height: 200,
                            width: 200,
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ),
                      ]),
          ),
        ),
      ),
    );
  }
}
