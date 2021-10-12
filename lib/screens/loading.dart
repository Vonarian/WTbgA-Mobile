import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  Future<void> loadData() async {
    await loadDiskValues();
    if (userInputOut != '' && userInputOut != null) {
      await Navigator.pushReplacementNamed(context, '/home',
          arguments: userInputOut);
    }
  }

  dynamic serverData;
  @override
  void initState() {
    super.initState();
    loadData();
  }

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
