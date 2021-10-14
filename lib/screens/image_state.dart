import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

  bool imageNotNull = false;
  dynamic serverData;
  String? ipAdd;
  bool active = false;
  // dynamic imageOut;
  dynamic imageData;
  @override
  void initState() {
    startServer();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      ipAdd = ModalRoute.of(context)!.settings.arguments as String?;
    });
    loadData();
    Timer.periodic(const Duration(milliseconds: 4500), (timer) async {
      loadData();
    });
    super.initState();
  }

  Future<void> startServer() async {
    var server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
    print("Server running on IP : " +
        server.address.toString() +
        " On Port : " +
        server.port.toString());
    await for (var request in server) {
      print(server.address.toString());
      request.response
        ..headers.contentType =
            new ContentType("text", "plain", charset: "utf-8")
        ..write('Hello, world')
        ..close();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
  // setImage() {
  //   print('setImage ran');
  //   if (!mounted) return;
  // }

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
                        centerTitle: true,
                        title: Text('Data Loading Failed'),
                      ),
                      body: Stack(
                        children: [
                          Center(
                              child: BlinkText(
                            'Unable to load data!',
                            duration: Duration(seconds: 0),
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 22,
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
