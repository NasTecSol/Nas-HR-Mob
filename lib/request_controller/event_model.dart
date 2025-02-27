class EventModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  List<Data>? data;

  EventModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  EventModel.fromJson(Map<String, dynamic> json) {
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
  String? eventName;
  String? eventDescription;
  String? eventType;
  String? createdBy;
  List<Members>? members;
  String? month;
  String? date;
  String? category;
  bool? isNotification;
  String? departmentId;
  String? createdAt;
  String? updatedAt;
  int? v;

  Data({this.id, this.eventName, this.eventDescription, this.eventType, this.createdBy, this.members, this.month, this.date, this.category, this.isNotification, this.departmentId, this.createdAt, this.updatedAt, this.v});

  Data.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    eventName = json["eventName"];
    eventDescription = json["eventDescription"];
    eventType = json["eventType"];
    createdBy = json["createdBy"];
    members = json["members"] == null ? null : (json["members"] as List).map((e) => Members.fromJson(e)).toList();
    month = json["month"];
    date = json["date"];
    category = json["category"];
    isNotification = json["isNotification"];
    departmentId = json["departmentId"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["eventName"] = eventName;
    _data["eventDescription"] = eventDescription;
    _data["eventType"] = eventType;
    _data["createdBy"] = createdBy;
    if(members != null) {
      _data["members"] = members?.map((e) => e.toJson()).toList();
    }
    _data["month"] = month;
    _data["date"] = date;
    _data["category"] = category;
    _data["isNotification"] = isNotification;
    _data["departmentId"] = departmentId;
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    return _data;
  }
}

class Members {
  String? employeeId;
  String? empId;
  String? name;
  String? designation;

  Members({this.employeeId, this.empId, this.name, this.designation});

  Members.fromJson(Map<String, dynamic> json) {
    employeeId = json["employeeId"];
    empId = json["empId"];
    name = json["name"];
    designation = json["designation"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["employeeId"] = employeeId;
    _data["empId"] = empId;
    _data["name"] = name;
    _data["designation"] = designation;
    return _data;
  }
}