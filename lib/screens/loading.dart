import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:blinking_text/blinking_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Loading extends ConsumerStatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends ConsumerState<Loading> {
  Future<void> loadData() async {
    await loadDiskValues();
    await AwesomeNotifications()
        .isNotificationAllowed()
        .then((isAllowed) async {
      print(isAllowed);

      if (!isAllowed) {
        await showDialog(
            context: context, builder: (BuildContext context) => errorDialog);
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    if (userInputOut != '' && userInputOut != null) {
      await Navigator.pushReplacementNamed(context, '/home',
          arguments: {'input': userInputOut});
    }
  }

  String? userInputOut;
  dynamic serverData;
  @override
  void initState() {
    super.initState();
    loadData();
  }

  late Dialog errorDialog = Dialog(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0)), //this right here
    child: Container(
      height: 30.0,
      width: 30.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(7.0),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Allow'),
              )),
        ],
      ),
    ),
  );

  loadDiskValues() async {
    await _prefs.then((SharedPreferences prefs) async {
      userInputOut = (prefs.getString('userInputOut') ?? '');
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
          decoration: const InputDecoration(hintText: '192.168.X.Y'),
        ),
      ),
    );
  }

  // void startServer() {
  //   HttpServer.bind(InternetAddress.anyIPv4, 54338).then((server) {
  //     server.listen((HttpRequest request) {
  //       print('data sent');
  //       Map<String, dynamic> serverData = {'mounted': mounted};
  //       request.response.write(jsonEncode(serverData));
  //       request.response.close();
  //     });
  //   });
  // }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Loading (Enter IP)'),
      ),
      body: Stack(
        children: [
          Center(
              child: Container(
            padding: EdgeInsets.only(bottom: 95),
            child: BlinkText(
              'Enter IP address',
              endColor: Colors.red,
              duration: Duration(seconds: 1),
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 21,
                  fontWeight: FontWeight.bold),
            ),
          )),
          Center(
              child: Container(
            height: 200,
            width: 200,
            child: CircularProgressIndicator(
              backgroundColor: Colors.red,
            ),
          )),
          Center(
            child: IconButton(
                iconSize: 40,
                onPressed: () async {
                  AwesomeNotifications()
                      .isNotificationAllowed()
                      .then((isAllowed) async {
                    if (!isAllowed) {
                      await showDialog(
                          context: context,
                          builder: (BuildContext context) => errorDialog);
                      AwesomeNotifications()
                          .requestPermissionToSendNotifications();
                    }
                  });

                  final SharedPreferences prefs = await _prefs;
                  userInputOut =
                      await Navigator.of(context).push(dialogBuilder(context));
                  String _userInputOut =
                      (prefs.getString('userInputOut') ?? '');
                  setState(() {
                    _userInputOut = userInputOut!;
                  });
                  prefs.setString('userInputOut', _userInputOut);
                  await Navigator.pushReplacementNamed(context, '/home',
                      arguments: {'input': userInputOut, 'state': 'home'});
                },
                icon: const Icon(Icons.cast_connected_outlined)),
          ),
        ],
      ),
    );
  }
}
