import 'package:flutter/material.dart';
import 'UserInfo.dart';
import 'BizRequest.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    checkLoginInfo(context);

    return Center();
  }

  void checkLoginInfo(BuildContext context) async {
    UserInfo userInfo = await BizRequest.readUserInfo();

    if (userInfo == null) {
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      if (DateTime.now().millisecondsSinceEpoch ~/ 1000 > userInfo.tokenRecordTime + userInfo.tokenActiveSeconds) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      Navigator.of(context).pushReplacementNamed('/main');
    }
  }
}
