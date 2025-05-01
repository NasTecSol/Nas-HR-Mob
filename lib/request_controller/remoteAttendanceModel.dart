class RemoteAttendanceModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  List<Data>? data;

  RemoteAttendanceModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  RemoteAttendanceModel.fromJson(Map<String, dynamic> json) {
    statusCode = json["statusCode"];
    statusMessage = json["statusMessage"];
    errorMessage = json["errorMessage"];
    data = json["data"] == null ? null : (json["data"] as List).map((e) => Data.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["statusCode"] = statusCode;
    _data["statusMessage"] = statusMessage;
    _data["errorMessage"] = errorMessage;
    if(data != null) {
      _data["data"] = data?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Data {
  String? employeeId;
  bool? isRemoteAttendance;
  String? remoteAttendanceLoc;

  Data({this.employeeId, this.isRemoteAttendance, this.remoteAttendanceLoc});

  Data.fromJson(Map<String, dynamic> json) {
    employeeId = json["employeeId"];
    isRemoteAttendance = json["isRemoteAttendance"];
    remoteAttendanceLoc = json["remoteAttendanceLoc"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["employeeId"] = employeeId;
    _data["isRemoteAttendance"] = isRemoteAttendance;
    _data["remoteAttendanceLoc"] = remoteAttendanceLoc;
    return _data;
  }
}