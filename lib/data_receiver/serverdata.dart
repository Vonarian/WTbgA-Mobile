import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';

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
  int? water;
  int? altitude;
  int? minFuel;
  int? maxFuel;
  int? gear;
  int? chatId1;
  int? chatId2;
  String? chatMsg1;
  String? chatMsg2;
  String? chatMode1;
  String? chatMode2;
  String? chatSender1;
  String? chatSender2;
  bool? chatEnemy1;
  bool? chatEnemy2;
  bool? active;
  dynamic image;

  ServerData(
      {this.vehicleName,
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
      this.chatId1,
      this.chatId2,
      this.chatMsg1,
      this.chatMsg2,
      this.chatEnemy1,
      this.chatEnemy2,
      this.chatMode1,
      this.chatMode2,
      this.chatSender1,
      this.chatSender2,
      required this.image,
      this.active});
  static Future<ServerData> getData(ipAddress, state) async {
    Map<String?, dynamic> stateMap = {'state': state, 'WTbgA': true};
    try {
      Response? response = await post(Uri.parse('http://$ipAddress'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(stateMap));
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
          water: data['water'],
          chatId1: data['chatId1'],
          chatId2: data['chatId2'],
          chatMsg1: data['chat1'],
          chatMsg2: data['chat2'],
          chatEnemy1: data['chatEnemy1'],
          chatEnemy2: data['chatEnemy2'],
          chatMode1: data['chatMode1'],
          chatMode2: data['chatMode2'],
          chatSender1: data['chatSender1'],
          chatSender2: data['chatSender2'],
          image: data['image'],
          active: data['active']);
    } catch (e, stackTrace) {
      log('Encountered error: $e', stackTrace: stackTrace);
      rethrow;
    }
  }
}
