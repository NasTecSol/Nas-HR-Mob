class AttendanceData {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  Data? data;

  AttendanceData({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  AttendanceData.fromJson(Map<String, dynamic> json) {
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
  List<Data1>? data;
  int? totalRecords;
  int? page;
  int? limit;
  int? totalPages;

  Data({this.data, this.totalRecords, this.page, this.limit, this.totalPages});

  Data.fromJson(Map<String, dynamic> json) {
    data = json["data"] == null ? null : (json["data"] as List).map((e) => Data1.fromJson(e)).toList();
    totalRecords = json["totalRecords"];
    page = json["page"];
    limit = json["limit"];
    totalPages = json["totalPages"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if(data != null) {
      _data["data"] = data?.map((e) => e.toJson()).toList();
    }
    _data["totalRecords"] = totalRecords;
    _data["page"] = page;
    _data["limit"] = limit;
    _data["totalPages"] = totalPages;
    return _data;
  }
}

class Data1 {
  String? id;
  String? employeeId;
  String? empId;
  String? name;
  String? companyId;
  String? branchId;
  String? date;
  String? clockInTime;
  String? clockOutTime;
  dynamic totalHoursWorked;
  String? location;
  String? status;
  List<Break>? breaksTaken;
  int? breakTime;
  int? lateMinutes;
  List<dynamic>? penalties;
  dynamic leaveDetails;
  String? shift;
  int? workingHoursPerday;
  dynamic earlyCheckOut;
  String? remarks;
  String? createdAt;
  String? updatedAt;
  int? v;

  Data1({this.id, this.employeeId, this.empId, this.name, this.companyId, this.branchId, this.date, this.clockInTime, this.clockOutTime, this.totalHoursWorked, this.location, this.status, this.breaksTaken, this.breakTime, this.lateMinutes, this.penalties, this.leaveDetails, this.shift, this.workingHoursPerday, this.earlyCheckOut, this.remarks, this.createdAt, this.updatedAt, this.v});

  Data1.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    employeeId = json["employeeId"];
    empId = json["empId"];
    name = json["name"];
    companyId = json["companyId"];
    branchId = json["branchId"];
    date = json["date"];
    clockInTime = json["clockInTime"];
    clockOutTime = json["clockOutTime"];
    totalHoursWorked = json["totalHoursWorked"];
    location = json["location"];
    status = json["status"];
    breaksTaken = json["breaksTaken"] != null
        ? (json["breaksTaken"] as List).map((e) => Break.fromJson(e)).toList()
        : [];
    breakTime = json["breakTime"];
    lateMinutes = json["lateMinutes"];
    penalties = json["penalties"] ?? [];
    leaveDetails = json["leaveDetails"];
    shift = json["shift"];
    workingHoursPerday = json["workingHoursPerday"];
    earlyCheckOut = json["earlyCheckOut"];
    remarks = json["remarks"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["employeeId"] = employeeId;
    _data["empId"] = empId;
    _data["name"] = name;
    _data["companyId"] = companyId;
    _data["branchId"] = branchId;
    _data["date"] = date;
    _data["clockInTime"] = clockInTime;
    _data["clockOutTime"] = clockOutTime;
    _data["totalHoursWorked"] = totalHoursWorked;
    _data["location"] = location;
    _data["status"] = status;
    if (breaksTaken != null) {
      _data["breaksTaken"] = breaksTaken!.map((e) => e.toJson()).toList();
    }
    _data["breakTime"] = breakTime;
    _data["lateMinutes"] = lateMinutes;
    if(penalties != null) {
      _data["penalties"] = penalties;
    }
    _data["leaveDetails"] = leaveDetails;
    _data["shift"] = shift;
    _data["workingHoursPerday"] = workingHoursPerday;
    _data["earlyCheckOut"] = earlyCheckOut;
    _data["remarks"] = remarks;
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    return _data;
  }
}

class Break {
  dynamic startTime;
  dynamic endTime;
  dynamic durationMinutes;

  Break({this.startTime, this.endTime, this.durationMinutes});

  Break.fromJson(Map<String, dynamic> json) {
    startTime = json["startTime"] != null ? DateTime.parse(json["startTime"]) : null;
    endTime = json["endTime"] != null ? DateTime.parse(json["endTime"]) : null;
    durationMinutes = json["durationMinutes"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = {};
    if (startTime != null) {
      _data["startTime"] = startTime!.toUtc().toIso8601String();
    }
    if (endTime != null) {
      _data["endTime"] = endTime!.toUtc().toIso8601String();
    }
    _data["durationMinutes"] = durationMinutes;
    return _data;
  }
}