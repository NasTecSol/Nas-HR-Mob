class TeamAttendanceModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  Data? data;

  TeamAttendanceModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  TeamAttendanceModel.fromJson(Map<String, dynamic> json) {
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
  List<TeamAttendanceData>? data;
  int? totalRecords;
  int? page;
  int? limit;
  int? totalPages;

  Data({this.data, this.totalRecords, this.page, this.limit, this.totalPages});

  Data.fromJson(Map<String, dynamic> json) {
    data = json["data"] == null ? null : (json["data"] as List).map((e) => TeamAttendanceData.fromJson(e)).toList();
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

class TeamAttendanceData {
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
  ShiftInfo? shiftInfo;
  List<Slots>? slots;
  dynamic workingHoursPerday;
  dynamic earlyCheckOut;
  dynamic remarks;
  dynamic createdAt;
  dynamic updatedAt;
  int? v;

  TeamAttendanceData({this.id, this.employeeId, this.empId, this.name, this.companyId, this.branchId, this.date, this.clockInTime, this.clockOutTime, this.totalHoursWorked, this.location, this.status,this.secondaryStatus ,this.breaksTaken, this.breakTime, this.lateMinutes, this.penalties, this.leaveDetails ,this.shift,this.shiftInfo ,this.slots, this.workingHoursPerday, this.earlyCheckOut, this.remarks, this.createdAt, this.updatedAt, this.v});

  TeamAttendanceData.fromJson(Map<String, dynamic> json) {
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
    shiftInfo = json["shiftInfo"] == null ? null : ShiftInfo.fromJson(json["shiftInfo"]);
    slots = json["slots"] == null
        ? null
        : (json["slots"] as List).whereType<Map<String, dynamic>>().map((e) => Slots.fromJson(e)).toList();
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
    if(shiftInfo != null) {
      _data["shiftInfo"] = shiftInfo?.toJson();
    }
    if(slots != null) {
      _data["slots"] = slots?.map((e) => e.toJson()).toList();
    }
    _data["workingHoursPerday"] = workingHoursPerday;
    _data["earlyCheckOut"] = earlyCheckOut;
    _data["remarks"] = remarks;
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    return _data;
  }
}

class ShiftInfo {
  String? timefrom;
  String? timeTo;
  String? shiftName;
  String? shiftType;

  ShiftInfo({this.timefrom, this.timeTo, this.shiftName, this.shiftType});

  ShiftInfo.fromJson(Map<String, dynamic> json) {
    timefrom = json["timefrom"];
    timeTo = json["timeTo"];
    shiftName = json["shiftName"];
    shiftType = json["shiftType"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["timefrom"] = timefrom;
    _data["timeTo"] = timeTo;
    _data["shiftName"] = shiftName;
    _data["shiftType"] = shiftType;
    return _data;
  }
}

class Slots {
  dynamic slotStart;
  dynamic slotEnd;
  dynamic checkInTime;
  dynamic checkOutTime;
  dynamic status;
  bool? isActive;
  List<dynamic>? breaksTaken;
  dynamic lateMinutes;
  dynamic earlyCheckOut;

  Slots({this.slotStart, this.slotEnd, this.checkInTime, this.checkOutTime, this.status, this.isActive, this.breaksTaken, this.lateMinutes, this.earlyCheckOut});

  Slots.fromJson(Map<String, dynamic> json) {
    slotStart = json["slotStart"];
    slotEnd = json["slotEnd"];
    checkInTime = json["checkInTime"];
    checkOutTime = json["checkOutTime"];
    status = json["status"];
    isActive = json["isActive"];
    breaksTaken = json["breaksTaken"] ?? [];
    lateMinutes = json["lateMinutes"];
    earlyCheckOut = json["earlyCheckOut"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["slotStart"] = slotStart;
    _data["slotEnd"] = slotEnd;
    _data["checkInTime"] = checkInTime;
    _data["checkOutTime"] = checkOutTime;
    _data["status"] = status;
    _data["isActive"] = isActive;
    if(breaksTaken != null) {
      _data["breaksTaken"] = breaksTaken;
    }
    _data["lateMinutes"] = lateMinutes;
    _data["earlyCheckOut"] = earlyCheckOut;
    return _data;
  }
}
class Penalties {
  int? uniqueId;
  String? action;
  int? percentage;
  int? lateMinute;
  int? occurrence;

  Penalties({this.uniqueId, this.action, this.percentage, this.lateMinute, this.occurrence});

  Penalties.fromJson(Map<String, dynamic> json) {
    uniqueId = json["uniqueId"];
    action = json["action"];
    percentage = json["percentage"];
    lateMinute = json["lateMinutes"];
    occurrence = json["occurrence"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["uniqueId"] = uniqueId;
    _data["action"] = action;
    _data["percentage"] = percentage;
    _data["lateMinutes"] = lateMinute;
    _data["occurrence"] = occurrence;
    return _data;
  }
}

class BreaksTaken {
  dynamic startTime;
  dynamic endTime;
  dynamic durationMinutes;

  BreaksTaken({this.startTime, this.endTime, this.durationMinutes});

  BreaksTaken.fromJson(Map<String, dynamic> json) {
    startTime = json["startTime"];
    endTime = json["endTime"];
    durationMinutes = json["durationMinutes"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["startTime"] = startTime;
    _data["endTime"] = endTime;
    _data["durationMinutes"] = durationMinutes;
    return _data;
  }
}