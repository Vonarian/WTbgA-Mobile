import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:blinking_text/blinking_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServerData {
  String? vehicleName;
  int? ias;
  int? tas;
  double? climb;
  int? damageId;
  String? damageMsg;
  double? critAoa;
  double? aoa;
  double? throttle;
  double? engineTemp;
  int? oil;
  dynamic water;
  int? altitude;
  int? minFuel;
  int? maxFuel;
  int? gear;
  ServerData({
    this.vehicleName,
    this.ias,
    this.tas,
    this.climb,
    this.damageId,
    this.damageMsg,
    this.critAoa,
    this.minFuel,
    this.gear,
    this.water,
    this.maxFuel,
    this.oil,
    this.altitude,
    this.aoa,
    this.engineTemp,
    this.throttle,
  });

  static Future<ServerData> getData(ipAddress) async {
    try {
      Response? response = await get(Uri.parse('http://$ipAddress'));
      Map<String, dynamic> data = jsonDecode(response.body);
      return ServerData(
          vehicleName: data['vehicleName'],
          ias: data['ias'],
          tas: data['tas'],
          climb: data['climb'],
          damageId: data['damageId'],
          damageMsg: data['damageMsg'],
          critAoa: data['critAoa'],
          aoa: data['aoa'],
          throttle: double.tryParse(data['throttle']),
          altitude: data['altitude'],
          engineTemp: data['engineTemp'],
          gear: data['gear'],
          maxFuel: data['maxFuel'],
          minFuel: data['minFuel'],
          oil: data['oil'],
          water: data['water']);
    } catch (e, stackTrace) {
      log('Encountered error: $e', stackTrace: stackTrace);
      rethrow;
    }
  }
}

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  Future<void> loadData() async {
    await loadDiskValues();
    if (userInputOut == null) return;
    await Navigator.pushReplacementNamed(context, '/home',
        arguments: userInputOut);
  }

  dynamic serverData;
  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadDiskValues() {
    _prefs.then((SharedPreferences prefs) async {
      userInputOut = (prefs.getString('userInputOut') ?? '');
      await Navigator.pushReplacementNamed(context, '/home',
          arguments: userInputOut);
    });
  }

  static Route<String> dialogBuilder(BuildContext context) {
    TextEditingController userInputController = TextEditingController();
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
                      content: Text('Server IP Address has been set')));
                Navigator.of(context).pop((userInputController.text));
              },
              child: const Text('Set IP')),
        ],
        title: const Text(
            'Enter server IP Address (Shown in sidebar menu of desktop WTbgA)'),
        content: TextField(
          onChanged: (value) {},
          controller: userInputController,
          decoration: const InputDecoration(hintText: "192.168.X.Y"),
        ),
      ),
    );
  }

  String? userInputOut;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Loading screen'),
      ),
      body: Stack(children: [
        const Center(child: CircularProgressIndicator()),
        Center(
          child: IconButton(
              iconSize: 40,
              onPressed: () async {
                final SharedPreferences prefs = await _prefs;
                userInputOut =
                    await Navigator.of(context).push(dialogBuilder(context));
                String _userInputOut = (prefs.getString('userInputOut') ?? '');

                setState(() {
                  _userInputOut = userInputOut!;
                });
                prefs.setString("userInputOut", _userInputOut);
                await Navigator.pushReplacementNamed(context, '/home',
                    arguments: userInputOut);
              },
              icon: const Icon(Icons.cast_connected_outlined)),
        )
      ]),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<void> updateData() async {
    if (userInputInHome == null || userInputInHome == '') return;
    // final WifiInfo _wifiInfo = WifiInfo();
    // String? wifiInfo;
    // wifiInfo = await _wifiInfo.getWifiIP();
    // print(wifiInfo);
    ServerData internalServerData =
        await ServerData.getData(userInputInHome ?? '');
    if (!mounted) return;
    setState(() {
      serverData = internalServerData;
      idData.value = serverData.damageId;
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
    });
  }

  static Route<int> dialogBuilder(BuildContext context) {
    return DialogRoute(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: const Text('Allow notification access?'),
              title: const Text('Notifications permission request '),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel')),
                ElevatedButton(
                    onPressed: () {
                      AwesomeNotifications()
                          .isNotificationAllowed()
                          .then((isAllowed) {
                        if (!isAllowed) {
                          // Insert here your friendly dialog box before call the request method
                          // This is very important to not harm the user experience
                          AwesomeNotifications()
                              .requestPermissionToSendNotifications();
                        }
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text('Allow'))
              ],
            ));
  }

  Future<void> notifications() async {
    if (isDamageIdNew && serverData.damageMsg == 'Engine overheated') {
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: 1,
              channelKey: 'basic_channel',
              title: 'Engine Overheated!',
              body: 'Engine is overheating'));
      isDamageIdNew = false;
      AwesomeNotifications().actionStream.listen((receivedNotification) async {
        await Navigator.of(context).pushReplacementNamed('/home');
      });
    }
    if (isDamageIdNew && serverMsg == 'Oil overheated') {
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: 2,
              channelKey: 'basic_channel',
              title: 'Oil Overheated!',
              body: 'Oil is overheating'));
      isDamageIdNew = false;
      AwesomeNotifications().actionStream.listen((receivedNotification) async {
        await Navigator.of(context).pushReplacementNamed('/home');
      });
    }
  }

  Future<void> loadInput() async {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      userInputInHome = ModalRoute.of(context)?.settings.arguments;
    });
  }

  @override
  void initState() {
    loadInput();
    idData.addListener(() {
      isDamageIdNew = true;
    });
    isDamageIdNew = false;
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      updateData();
      notifications();
      stallDetector();
    });
  }

  @override
  void dispose() {
    idData.removeListener(() => isDamageIdNew = true);
    super.dispose();
  }

  void stallDetector() {
    if (aoa != null && critAoa != null && climb != null && aoa! >= -critAoa!) {
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
                        fontWeight: FontWeight.bold, fontSize: 20))
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
              child: Text(
                'Currently running on $userInputInHome',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              onPressed: () async {
                userInputInHome = await Navigator.of(context)
                    .push(dialogBuilderForIP(context));
              },
              child: const Text('Update server IP'),
            )
          ],
        ),
      ),
    );
  }

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
  String? serverMsg;
  String? vehicleName;
  String? wifiIP;
  String icon = 'assets/app_icon.ico';
  ValueNotifier<int?> idData = ValueNotifier(null);
  bool isDamageIdNew = false;
  bool critAoaBool = false;
  dynamic serverData;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Builder(builder: (context) {
          return drawerBuilder();
        }),
        backgroundColor: Colors.blueGrey,
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () async {
                await Navigator.of(context).push(dialogBuilder(context));
              },
              icon: const Icon(Icons.notifications),
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
              iasText(),
              tasText(),
              waterText(),
              climbText(),
            ],
          ),
        ),
      ),
    );
  }
}
