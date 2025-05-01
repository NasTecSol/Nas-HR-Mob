class BaseUrlModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  String? data;

  BaseUrlModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  BaseUrlModel.fromJson(Map<String, dynamic> json) {
    statusCode = json["statusCode"];
    statusMessage = json["statusMessage"];
    errorMessage = json["errorMessage"];
    data = json["data"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["statusCode"] = statusCode;
    _data["statusMessage"] = statusMessage;
    _data["errorMessage"] = errorMessage;
    _data["data"] = data;
    return _data;
  }
}