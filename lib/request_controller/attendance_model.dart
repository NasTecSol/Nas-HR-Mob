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
  dynamic totalRecords;
  dynamic page;
  dynamic limit;
  dynamic totalPages;

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
  dynamic id;
  dynamic employeeId;
  dynamic empId;
  dynamic name;
  dynamic companyId;
  dynamic branchId;
  dynamic date;
  dynamic clockInTime;
  dynamic clockOutTime;
  dynamic totalHoursWorked;
  dynamic location;
  dynamic status;
  dynamic secondaryStatus;
  List<dynamic>? breaksTaken;
  dynamic breakTime;
  dynamic lateMinutes;
  List<Penalties>? penalties;
  dynamic leaveDetails;
  dynamic shift;
  dynamic workingHoursPerday;
  dynamic earlyCheckOut;
  dynamic remarks;
  dynamic createdAt;
  dynamic updatedAt;
  int? v;

  Data1({this.id, this.employeeId, this.empId, this.name, this.companyId, this.branchId, this.date, this.clockInTime, this.clockOutTime, this.totalHoursWorked, this.location, this.status, this.secondaryStatus ,this.breaksTaken, this.breakTime, this.lateMinutes, this.penalties, this.leaveDetails, this.shift, this.workingHoursPerday, this.earlyCheckOut, this.remarks, this.createdAt, this.updatedAt, this.v});

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
    secondaryStatus = json["secondaryStatus"];
    breaksTaken = json["breaksTaken"] ?? [];
    breakTime = json["breakTime"];
    lateMinutes = json["lateMinutes"];
    penalties = json["penalties"] == null
        ? null
        : (json["penalties"] as List).whereType<Map<String, dynamic>>().map((e) => Penalties.fromJson(e)).toList();
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
    _data["secondaryStatus"] = secondaryStatus;
    if(breaksTaken != null) {
      _data["breaksTaken"] = breaksTaken;
    }
    _data["breakTime"] = breakTime;
    _data["lateMinutes"] = lateMinutes;
    if(penalties != null) {
      _data["penalties"] = penalties?.map((e) => e.toJson()).toList();
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

class Penalties {
  dynamic uniqueId;
  dynamic action;
  dynamic percentage;
  dynamic lateMinute;
  dynamic occurrence;

  Penalties({this.uniqueId, this.action, this.percentage, this.lateMinute, this.occurrence});

  Penalties.fromJson(Map<String, dynamic> json) {
    uniqueId = json["uniqueId"];
    action = json["action"];
    percentage = json["percentage"];
    lateMinute = json["lateMinute"];
    occurrence = json["occurrence"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["uniqueId"] = uniqueId;
    _data["action"] = action;
    _data["percentage"] = percentage;
    _data["lateMinute"] = lateMinute;
    _data["occurrence"] = occurrence;
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