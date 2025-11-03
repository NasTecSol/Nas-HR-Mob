class BiometricDevicesModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  List<Data>? data;

  BiometricDevicesModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  BiometricDevicesModel.fromJson(Map<String, dynamic> json) {
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
  String? deviceName;
  String? deviceId;
  String? socket;
  String? password;
  String? usedAs;
  String? doorType;
  String? manufacturer;
  String? branchId;
  String? companyId;
  String? location;
  String? createdBy;
  String? createdAt;
  String? updatedAt;
  int? v;
  String? lastSeen;

  Data({this.id, this.deviceName, this.deviceId, this.socket, this.password, this.usedAs, this.doorType, this.manufacturer, this.branchId, this.companyId, this.location, this.createdBy, this.createdAt, this.updatedAt, this.v, this.lastSeen});

  Data.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    deviceName = json["deviceName"];
    deviceId = json["deviceId"];
    socket = json["socket"];
    password = json["password"];
    usedAs = json["usedAs"];
    doorType = json["doorType"];
    manufacturer = json["manufacturer"];
    branchId = json["branchId"];
    companyId = json["companyId"];
    location = json["location"];
    createdBy = json["createdBy"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
    lastSeen = json["lastSeen"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["deviceName"] = deviceName;
    _data["deviceId"] = deviceId;
    _data["socket"] = socket;
    _data["password"] = password;
    _data["usedAs"] = usedAs;
    _data["doorType"] = doorType;
    _data["manufacturer"] = manufacturer;
    _data["branchId"] = branchId;
    _data["companyId"] = companyId;
    _data["location"] = location;
    _data["createdBy"] = createdBy;
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    _data["lastSeen"] = lastSeen;
    return _data;
  }
}