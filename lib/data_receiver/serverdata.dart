// class ServerData {
//   String? vehicleName;
//   int? ias;
//   int? tas;
//   double? climb;
//   int? damageId;
//   String? damageMsg;
//   double? critAoa;
//   double? aoa;
//   double? throttle;
//   double? engineTemp;
//   int? oil;
//   int? water;
//   int? altitude;
//   int? minFuel;
//   int? maxFuel;
//   int? gear;
//   int? chatId1;
//   int? chatId2;
//   String? chatMsg1;
//   String? chatMsg2;
//   String? chatMode1;
//   String? chatMode2;
//   String? chatSender1;
//   String? chatSender2;
//   bool? chatEnemy1;
//   bool? chatEnemy2;
//
//   ServerData(
//       {this.vehicleName,
//       this.ias,
//       this.tas,
//       this.climb,
//       this.damageId,
//       this.damageMsg,
//       this.critAoa,
//       this.minFuel,
//       this.gear,
//       this.water,
//       this.maxFuel,
//       this.oil,
//       this.altitude,
//       this.aoa,
//       this.engineTemp,
//       this.throttle,
//       this.chatId1,
//       this.chatId2,
//       this.chatMsg1,
//       this.chatMsg2,
//       this.chatEnemy1,
//       this.chatEnemy2,
//       this.chatMode1,
//       this.chatMode2,
//       this.chatSender1,
//       this.chatSender2});

// {
// if (ws.readyState == WebSocket.open) {
// ws.add(json.encode(stateMap));
// ws.listen(
// (data) {
// Timer(Duration(seconds: 1), () {
// if (ws.readyState == WebSocket.open) ws.add(json.encode(stateMap));
// });
// },
// onDone: () => print('[+]Done :)'),
// onError: (err) => print('[!]Error -- ${err.toString()}'),
// cancelOnError: false,
// );
// } else {
// print('[!]Connection Denied');
// }
// }
