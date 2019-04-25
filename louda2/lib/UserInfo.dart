
final UserInfoFile = "UserInfo.json";

class UserInfo {

  final String phone;
  final String token;
  final int tokenActiveSeconds;
  String qrcodeContent;
  int tokenRecordTime;

  UserInfo(this.phone, this.token, this.tokenActiveSeconds, { this.qrcodeContent, this.tokenRecordTime});

  UserInfo.fromJson(Map<String, dynamic> json):
        phone = json['phone'],
        token = json['token'],
        tokenActiveSeconds = json['tokenActiveSeconds'],
        qrcodeContent = json['qrcodeContent'],
        tokenRecordTime = json['tokenRecordTime'];

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'token': token,
    'tokenActiveSeconds': tokenActiveSeconds,
    'qrcodeContent': qrcodeContent,
    'tokenRecordTime': tokenRecordTime
  };
}