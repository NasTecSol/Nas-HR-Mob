class RemoteAttendanceModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  Data? data;

  RemoteAttendanceModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  RemoteAttendanceModel.fromJson(Map<String, dynamic> json) {
    statusCode = json["statusCode"];
    statusMessage = json["statusMessage"];
    errorMessage = json["errorMessage"];
    data = json["data"] == null ? null : Data.fromJson(json["data"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["statusCode"] = statusCode;
    _data["statusMessage"] = statusMessage;
    _data["errorMessage"] = errorMessage;
    if(data != null) {
      _data["data"] = data?.toJson();
    }
    return _data;
  }
}

class Data {
  bool? isRemoteAttendance;
  String? remoteAttendanceLoc;

  Data({this.isRemoteAttendance, this.remoteAttendanceLoc});

  Data.fromJson(Map<String, dynamic> json) {
    isRemoteAttendance = json["isRemoteAttendance"];
    remoteAttendanceLoc = json["remoteAttendanceLoc"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["isRemoteAttendance"] = isRemoteAttendance;
    _data["remoteAttendanceLoc"] = remoteAttendanceLoc;
    return _data;
  }
}