
class TeamClockingModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  List<TeamClockingData>? data;

  TeamClockingModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  TeamClockingModel.fromJson(Map<String, dynamic> json) {
    statusCode = json["statusCode"];
    statusMessage = json["statusMessage"];
    errorMessage = json["errorMessage"];
    data = json["data"] == null ? null : (json["data"] as List).map((e) => TeamClockingData.fromJson(e)).toList();
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

class TeamClockingData {
  String? id;
  String? employeeId;
  String? employeeName;
  String? checkInTime;
  String? type;
  String? createdAt;
  String? updatedAt;
  int? v;
  String? checkOutTime;
  String? totalTime;

  TeamClockingData({this.id, this.employeeId, this.employeeName, this.checkInTime, this.type, this.createdAt, this.updatedAt, this.v, this.checkOutTime, this.totalTime});

  TeamClockingData.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    employeeId = json["employeeId"];
    employeeName = json["employeeName"];
    checkInTime = json["checkInTime"];
    type = json["type"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
    checkOutTime = json["checkOutTime"];
    totalTime = json["totalTime"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["employeeId"] = employeeId;
    _data["employeeName"] = employeeName;
    _data["checkInTime"] = checkInTime;
    _data["type"] = type;
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    _data["checkOutTime"] = checkOutTime;
    _data["totalTime"] = totalTime;
    return _data;
  }
}