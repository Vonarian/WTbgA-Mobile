// import 'dart:typed_data';

import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../main.dart';

class ImageState extends ConsumerStatefulWidget {
  const ImageState({Key? key}) : super(key: key);

  @override
  _ImageStateState createState() => _ImageStateState();
}

class _ImageStateState extends ConsumerState<ImageState> {
  // saveFileFromBase64String(String path, String base64String) =>
  //     File(path).writeAsBytes(base64Decode(base64String));

  // startServer() async {
  //   Future.delayed(Duration(milliseconds: 800), () {
  //     final arguments = ModalRoute.of(context)!.settings.arguments as Map;
  //     ipAdd = arguments['input'];
  //     Future.delayed(Duration(milliseconds: 800), () async {
  //       print(ipAdd);
  //       stream = await ObsWebSocket.connect(
  //           timeout: Duration(seconds: 3), connectUrl: 'ws://${ipAdd}:4444');
  //     });
  // state.state = arguments['state'];
  // HttpServer.bind(InternetAddress.anyIPv4, 55200).then((HttpServer server) {
  //   print('[+]WebSocket listening at -- ws://$phoneIP:55200');
  //   server.listen((HttpRequest request) {
  //     WebSocketTransformer.upgrade(request).then((WebSocket ws) {
  //       ws.listen(
  //         (data) {
  //           Timer(Duration(seconds: 1), () {
  //             if (ws.readyState == WebSocket.open) print(data);
  //             print(data);
  //             // checking connection state helps to avoid unprecedented errors
  //             ws.add(json.encode(serverData));
  //           });
  //         },
  //         onDone: () {
  //           ws.addError("Error");
  //           print('[+]Done :)');
  //         },
  //         onError: (err) => print('[!]Error -- ${err.toString()}'),
  //         cancelOnError: false,
  //       );
  //     }, onError: (err) => print('[!]Error -- ${err.toString()}'));
  //   }, onError: (err) => print('[!]Error -- ${err.toString()}'));
  // }, onError: (err) => print('[!]Error -- ${err.toString()}'));
  // });
  // }

  // Future<VideoPlayerController> createVideoPlayer() async {
  //   imageData = base64Decode(serverImage);
  //   final VideoPlayerController controller =
  //       VideoPlayerController.contentUri(imageData);
  //   await controller.initialize();
  //   await controller.setLooping(true);
  //   return controller;
  // }

  // loadData() async {
  //   try {
  //     Response? response = await get(Uri.parse('http://192.168.43.8:30000'));
  //
  //     Map<String, dynamic> data = jsonDecode(response.body);
  //     imageData = base64Decode(data['image']);
  //     print(data);
  //   } catch (e, stackTrace) {
  //     log(e.toString(), stackTrace: stackTrace);
  //     print(imageData);
  //   }
  // }
  final FijkPlayer player = FijkPlayer();

  @override
  void initState() {
    // _videoPlayerController = VlcPlayerController.network(
    //   'rtmp://192.168.43.8:1935',
    //   hwAcc: HwAcc.FULL,
    //   autoPlay: true,
    //   options: VlcPlayerOptions(),
    // );
    var state = ref.read(stateProvider);
    if (!mounted) return;
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      ipAdd = arguments['input'];
      state.state = arguments['state'];
      player.setDataSource("rtmp://$ipAdd:1935", autoPlay: true);

    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Future<void> giveIps() async {
  //   for (var interface in await NetworkInterface.list()) {
  //     for (var addr in interface.addresses) {
  //       phoneIP = addr.address;
  //       // print(phoneIP);
  //     }
  //   }
  // }

  // setImage() {
  //   print('setImage ran');
  //   if (!mounted) return;
  // }
  var imageData;
  var serverInfo;
  bool imageNotNull = false;
  String? ipAdd;
  bool active = false;
  WebSocketChannel? homeStream;
  var serverImage;
  // var phoneIP;
  // dynamic imageOut;
  // dynamic imageData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InteractiveViewer(
            child: Center(
          child: FijkView(player: player),
        )),
      ),
    );
  }
}
