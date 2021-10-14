import 'dart:async';
import 'dart:convert';

// import 'dart:typed_data';

import 'package:blinking_text/blinking_text.dart';
import 'package:flutter/material.dart';
import 'package:wtbgamobile/data_receiver/serverdata.dart';

class ImageState extends StatefulWidget {
  const ImageState({Key? key}) : super(key: key);

  @override
  _ImageStateState createState() => _ImageStateState();
}

class _ImageStateState extends State<ImageState> {
  // saveFileFromBase64String(String path, String base64String) =>
  //     File(path).writeAsBytes(base64Decode(base64String));
  Future<void> loadData() async {
    serverData = await ServerData.getData(ipAdd);
    if (!mounted) return;
    imageData = base64Decode(serverData.image);
    active = serverData.active;
    setState(() {
      print('image set');
    });
  }

  @override
  void initState() {
    if (!mounted) return;
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      print('${arguments['state']} is state in image');
      serverInfo = arguments['server'];
      ipAdd = arguments['input'];
      state = arguments['state'];
      setState(() {});
    });
    loadData();
    Timer.periodic(const Duration(milliseconds: 4500), (timer) async {
      loadData();
      // print(serverInfo);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // setImage() {
  //   print('setImage ran');
  //   if (!mounted) return;
  // }
  var serverInfo;
  bool imageNotNull = false;
  dynamic serverData;
  String? ipAdd;
  bool active = false;
  // dynamic imageOut;
  dynamic imageData;
  String? state;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: InteractiveViewer(
              child: active
                  ? Center(
                      child: Image.memory(
                        imageData,
                        // fit: BoxFit.fitWidth,
                        // width: MediaQuery.of(context).size.width,
                        // height: MediaQuery.of(context).size.height,
                      ),
                    )
                  : Scaffold(
                      appBar: AppBar(
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back_outlined),
                          onPressed: () async {
                            state = 'home';
                            await Navigator.pushReplacementNamed(
                                context, '/home',
                                arguments: {'state': state});
                          },
                        ),
                        automaticallyImplyLeading: false,
                        centerTitle: true,
                        title: Text('Data Loading Failed'),
                      ),
                      body: Stack(
                        children: [
                          Center(
                              child: BlinkText(
                            'Enable stream mode',
                            duration: Duration(seconds: 1),
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 21,
                                fontWeight: FontWeight.bold),
                          )),
                          Center(
                              child: SizedBox(
                            height: 200,
                            width: 200,
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.red,
                            ),
                          ))
                        ],
                      ),
                    )),
        ),
      ),
    );
  }
}
