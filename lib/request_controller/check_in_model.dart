
class CheckInData {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  Data? data;

  CheckInData({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  CheckInData.fromJson(Map<String, dynamic> json) {
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
  String? employeeId;
  String? employeeName;
  String? checkInTime;
  String? checkOutTime;
  String? type;
  String? totalTime;
  String? id;
  String? createdAt;
  String? updatedAt;
  int? v;

  Data({this.employeeId, this.employeeName, this.checkInTime, this.checkOutTime, this.type, this.totalTime, this.id, this.createdAt, this.updatedAt, this.v});

  Data.fromJson(Map<String, dynamic> json) {
    employeeId = json["employeeId"];
    employeeName = json["employeeName"];
    checkInTime = json["checkInTime"];
    checkOutTime = json["checkOutTime"];
    type = json["type"];
    totalTime = json["totalTime"];
    id = json["_id"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["employeeId"] = employeeId;
    _data["employeeName"] = employeeName;
    _data["checkInTime"] = checkInTime;
    _data["checkOutTime"] = checkOutTime;
    _data["type"] = type;
    _data["totalTime"] = totalTime;
    _data["_id"] = id;
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    return _data;
  }
}