import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'BizRequest.dart';
import 'Indicator.dart';

class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final indicatorController = IndicatorController();
  final qrCodeController = QRContentController();

  final messageChannel = const BasicMessageChannel<Object>('flutter/lifecycle', StringCodec());

  var isloading = false;

  @override
  void initState() {
    super.initState();

    loadQRContent();

    messageChannel.setMessageHandler((message) async {

      if(message == 'AppLifecycleState.resumed') {

        loadQRContent();
      }
    });
  }

  loadQRContent() async {
    if (isloading == true) {
      return;
    }

    isloading = true;

    final userInfo = await BizRequest.readUserInfo();

    indicatorController.isHidden = false;

    final r = await BizRequest.rule(userInfo.phone, userInfo.token);

    indicatorController.isHidden = true;

    isloading = false;

    if (r.result == true) {
      qrCodeController.value = r.msg;
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('开闸'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await BizRequest.clearUserInfo();
          Navigator.of(context).pushReplacementNamed('/login');
        },
        child: Text('X'),
      ),
      body: GestureDetector(
        onTap: () {
          loadQRContent();
        },
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Indicator(indicatorController),
              Expanded(
                child: Center(
                  child: QRContent(qrCodeController),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QRContent extends StatefulWidget {
  QRContentController controller;

  QRContent(QRContentController controller) : this.controller = controller;

  @override
  QRContentState createState() => QRContentState();
}

class QRContentState extends State<QRContent> {
  String qrCode = '';
  int version = 8;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() {
      qrCode = widget.controller.qrContent;
      version = widget.controller.version;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (qrCode.isEmpty) {
      return Text('');
    }

    return QrImage(version: version, size: 200, errorCorrectionLevel: 2, data: qrCode);
  }
}

class QRContentController extends ValueNotifier<String> {
  QRContentController() : super('');

  String get qrContent => value;

  int get version => eFunction(value);

  final dVar = [
    [17, 14, 11, 7],
    [32, 26, 20, 14],
    [53, 42, 32, 24],
    [78, 62, 46, 34],
    [106, 84, 60, 44],
    [134, 106, 74, 58],
    [154, 122, 86, 64],
    [192, 152, 108, 84],
    [230, 180, 130, 98],
    [271, 213, 151, 119],
    [321, 251, 177, 137],
    [367, 287, 203, 155],
    [425, 331, 241, 177],
    [458, 362, 258, 194],
    [520, 412, 292, 220],
    [586, 450, 322, 250],
    [644, 504, 364, 280],
    [718, 560, 394, 310],
    [792, 624, 442, 338],
    [858, 666, 482, 382],
    [929, 711, 509, 403],
    [1003, 779, 565, 439],
    [1091, 857, 611, 461],
    [1171, 911, 661, 511],
    [1273, 997, 715, 535],
    [1367, 1059, 751, 593],
    [1465, 1125, 805, 625],
    [1528, 1190, 868, 658],
    [1628, 1264, 908, 698],
    [1732, 1370, 982, 742],
    [1840, 1452, 1030, 790],
    [1952, 1538, 1112, 842],
    [2068, 1628, 1168, 898],
    [2188, 1722, 1228, 958],
    [2303, 1809, 1283, 983],
    [2431, 1911, 1351, 1051],
    [2563, 1989, 1423, 1093],
    [2699, 2099, 1499, 1139],
    [2809, 2213, 1579, 1219],
    [2953, 2331, 1663, 1273]
  ];

  int rFunction(String t) {
    var encoded = Uri.encodeFull(t);
    encoded = encoded.replaceAll(RegExp('\%[0-9a-fA-F]{2}'), 'a');
    //  int e = encoded.length + (encoded.length != t ? 3 : 0);
    int l = encoded.length + 3;
    return l;
  }

  int eFunction(String t, {int e = 2}) {
    final d = dVar;
    var o = 1;
    var n = rFunction(t);
    var a = d.length;
    for (var i = 0; i <= a; i++) {
      var s = 0;
      switch (e) {
        case 2:
          s = d[i][3];
      }
      if (n <= s) break;
      o++;
    }
    if (o > d.length) return 9999;
    return o;
  }
}
