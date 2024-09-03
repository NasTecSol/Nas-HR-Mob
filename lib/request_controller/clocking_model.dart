
class ClockingData {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  List<Data>? data;

  ClockingData({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  ClockingData.fromJson(Map<String, dynamic> json) {
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
  String? id;
  String? employeeId;
  String? employeeName;
  String? checkInTime;
  String? checkOutTime;
  String? type;
  String? totalTime;
  String? createdAt;
  String? updatedAt;
  int? v;

  Data({this.id, this.employeeId, this.employeeName, this.checkInTime, this.checkOutTime, this.type, this.totalTime, this.createdAt, this.updatedAt, this.v});

  Data.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    employeeId = json["employeeId"];
    employeeName = json["employeeName"];
    checkInTime = json["checkInTime"];
    checkOutTime = json["checkOutTime"];
    type = json["type"];
    totalTime = json["totalTime"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["employeeId"] = employeeId;
    _data["employeeName"] = employeeName;
    _data["checkInTime"] = checkInTime;
    _data["checkOutTime"] = checkOutTime;
    _data["type"] = type;
    _data["totalTime"] = totalTime;
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    return _data;
  }
}