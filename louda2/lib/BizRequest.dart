import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'UserInfo.dart';

class RequestResult {
  var msg = '';
  var result = false;

  RequestResult(result, msg)
      : this.msg = msg,
        this.result = result;
}

class BizRequest {
  static final header = {'Content-Type': 'application/json', 'Accept-Encoding': 'gzip, deflate'};

  static Future<RequestResult> sendVerify(String phoneNumber) async {
    final url = 'https://ivms.lx2.com/louxe-mall-api/sms/sendVerify.do';

    final mapBody = {
      'sysCode': 'WX_MINI_APP',
      'token': '',
      'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'sign': Uuid().v4().replaceAll('-', '').toUpperCase(),
      'version': '4.8.0',
      'data': {'bizType': 'T00', 'phone': phoneNumber}
    };

    final body = json.encode(mapBody);

    final response = await http.post(url, headers: header, body: body);

    if (response.statusCode != 200) {
      return RequestResult(false, '服务错误');
    }

    final map = json.decode(response.body);
    if (map is Map) {
      if (map['code'] == '200') {
        return RequestResult(true, '');
      } else {
        return RequestResult(false, map['msg']);
      }
    }
    return RequestResult(false, '数据错误');
  }

  static Future<RequestResult> fastLoginIncludeRegi(String phoneNumber, String smsCode) async {
    final url = 'https://ivms.lx2.com/louxe-mall-api/user/fastLoginIncludeRegi.do';

    final mapBody = {
      'sysCode': 'WX_MINI_APP',
      'token': '',
      'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'sign': Uuid().v4().replaceAll('-', '').toUpperCase(),
      'version': '4.8.0',
      'data': {'verify': smsCode, 'phone': phoneNumber}
    };

    final body = json.encode(mapBody);

    final response = await http.post(url, headers: header, body: body);

    if (response.statusCode != 200) {
      return RequestResult(false, '服务错误');
    }

    final map = json.decode(response.body);
    if (map is Map) {
      if (map['code'] == '200') {
        final secret = map['data']['secret'];

        final token = secret['token'];
        final tokenActiveSeconds = secret['tokenActiveSeconds'];

        final tokenRecordTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        final userInfo = UserInfo(phoneNumber, token, tokenActiveSeconds, tokenRecordTime: tokenRecordTime);
        await writeUserInfo(userInfo);

        return RequestResult(true, '');

  //      final rr = await rule(phoneNumber, token);

 //       return rr;
      } else {
        return RequestResult(false, map['msg']);
      }
    }
    return RequestResult(false, '数据错误');
  }

  static Future<RequestResult> rule(String phoneNumber, String token) async {
    final url = 'https://ivms.lx2.com/louxe-mall-api/qrcode/rule.do';

    final mapBody = {
      'sysCode': 'WX_MINI_APP',
      'token': token,
      'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'sign': Uuid().v4().replaceAll('-', '').toUpperCase(),
      'version': '4.8.0',
      'data': {'builCode': '440106B008', 'userName': phoneNumber}
    };

    final body = json.encode(mapBody);

    final response = await http.post(url, headers: header, body: body);

    if (response.statusCode != 200) {
      return RequestResult(false, '服务错误');
    }

    final map = json.decode(response.body);
    if (map is Map) {
      if (map['code'] == '200') {
        final qrcodeContent = map['data']['qrcodeContent'];

//        var userInfo = await readUserInfo();
//        assert(userInfo != null);
//        userInfo.qrcodeContent = qrcodeContent;
//
//        await writeUserInfo(userInfo);

        return RequestResult(true, qrcodeContent);
      } else {
        return RequestResult(false, map['msg']);
      }
    }
    return RequestResult(false, '数据错误');
  }

  static Future<UserInfo> readUserInfo() async {

    final path = (await getApplicationDocumentsDirectory()).path + '/' + UserInfoFile;

    final file = File(path);
    if (await file.exists()) {
      final jsonStr = await file.readAsString();

      final userInfoMap = json.decode(jsonStr);
      final userInfo = UserInfo.fromJson(userInfoMap);
      return userInfo;
    }

    return null;
  }

  static writeUserInfo(UserInfo userInfo) async {

    final path = (await getApplicationDocumentsDirectory()).path + '/' + UserInfoFile;

    final str = json.encode(userInfo.toJson());
    final file = File(path);

    await file.writeAsString(str);
  }

  static clearUserInfo() async {

    final path = (await getApplicationDocumentsDirectory()).path + '/' + UserInfoFile;

    final file = File(path);
    await file.delete();
  }
}
