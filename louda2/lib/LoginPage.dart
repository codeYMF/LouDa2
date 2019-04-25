import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'BizRequest.dart';
import 'Indicator.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  FocusNode secondTextFieldNode = FocusNode();
  final phoneTextController = TextEditingController();
  final codeTextController = TextEditingController();
  final indicatorController = IndicatorController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('登录'),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Indicator(indicatorController),
                Padding(padding: const EdgeInsets.fromLTRB(10, 20, 10, 20)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 40,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextInput('请输入手机号码', phoneTextController, true, secondTextFieldNode),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                        ),
                        SendSMSButton(() {
                          sendSMS(context);
                        }),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 40,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: TextInput('请输入验证码', codeTextController, false, secondTextFieldNode)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                  child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 40,
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: CupertinoButton(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Text(
                                '登录',
                              ),
                              color: Colors.blue,
                              onPressed: () {
                                login(context);
                              },
                            ),
                          )
                        ],
                      )),
                )
              ],
            ),
          ),
        ));
  }

  void sendSMS(BuildContext context) async {
    indicatorController.isHidden = false;

    final rr = await BizRequest.sendVerify(phoneTextController.text);

    indicatorController.isHidden = true;

    showDialog(
        context: context,
        builder: (_) => AlertDialog(title: Text(rr.result == true ? '提示' : '错误'), content: Text(rr.result == true ? '发送成功' : rr.msg), actions: <Widget>[
              CupertinoButton(
                child: new Text('确定'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ]));
  }

  void login(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());

    indicatorController.isHidden = false;

    final rr = await BizRequest.fastLoginIncludeRegi(phoneTextController.text, codeTextController.text);

    indicatorController.isHidden = true;

    if (rr.result == false) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(title: Text('错误'), content: Text(rr.msg), actions: <Widget>[
                CupertinoButton(
                  child: new Text('确定'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ]));
    } else {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }
}

class TextInput extends StatelessWidget {
  String title = "";
  TextEditingController controller;
  bool isSendNextFocus;
  FocusNode focusNode;

  TextInput(String title, TextEditingController controller, bool isSendNextFocus, FocusNode focusNode)
      : this.title = title,
        this.controller = controller,
        this.isSendNextFocus = isSendNextFocus,
        this.focusNode = focusNode;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      cursorColor: Colors.blue,
      textInputAction: TextInputAction.next,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(contentPadding: EdgeInsets.all(10.0), border: OutlineInputBorder(), hintText: title, hintStyle: TextStyle(color: Colors.blue)),
      autofocus: isSendNextFocus == true ? true : false,
      focusNode: isSendNextFocus == true ? null : focusNode,
      onEditingComplete: () {
        if (isSendNextFocus == true) FocusScope.of(context).requestFocus(focusNode);
      },
    );
  }
}

class SendSMSButton extends StatefulWidget {
  VoidCallback onPressed = null;

  SendSMSButton(VoidCallback onPressed) : this.onPressed = onPressed;

  @override
  SendSMSButtonState createState() => SendSMSButtonState();
}

class SendSMSButtonState extends State<SendSMSButton> {
  Timer _timer;
  int count = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Text(_timer == null ? "获取验证码" : '$count秒'),
      color: Colors.blue,
      onPressed: _timer == null
          ? () {
              startTime();

              if (widget.onPressed != null) {
                widget.onPressed();
              }
            }
          : null,
    );
  }

  void startTime() {
    if (_timer == null) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          count += 1;

          if (count > 30) {
            _timer.cancel();
            _timer = null;
            count = 0;
          }
        });
      });
    }
  }
}
