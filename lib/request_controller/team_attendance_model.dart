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
  dynamic totalRecords;
  dynamic page;
  dynamic limit;
  dynamic totalPages;

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
  LeaveDetails? leaveDetails;
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
    leaveDetails = json["leaveDetails"] == null ? null : LeaveDetails.fromJson(json["leaveDetails"]);
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
    if(leaveDetails != null) {
      _data["leaveDetails"] = leaveDetails?.toJson();
    }
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

class LeaveDetails {
  dynamic leaveType;
  dynamic leaveRequestId;
  dynamic isCompensatory;
  RequestInfo? requestInfo;

  LeaveDetails({this.leaveType, this.leaveRequestId, this.isCompensatory, this.requestInfo});

  LeaveDetails.fromJson(Map<String, dynamic> json) {
    leaveType = json["leaveType"];
    leaveRequestId = json["leaveRequestId"];
    isCompensatory = json["isCompensatory"];
    requestInfo = json["requestInfo"] == null ? null : RequestInfo.fromJson(json["requestInfo"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["leaveType"] = leaveType;
    _data["leaveRequestId"] = leaveRequestId;
    _data["isCompensatory"] = isCompensatory;
    if(requestInfo != null) {
      _data["requestInfo"] = requestInfo?.toJson();
    }
    return _data;
  }
}
class RequestInfo {
  dynamic id;
  dynamic employeeId;
  dynamic employeeName;
  dynamic empId;
  dynamic companyId;
  dynamic branchId;
  dynamic policyId;
  dynamic requestType;
  dynamic subType;
  List<RequestData>? requestData;
  List<Approvers>? approvers;
  dynamic reason;
  List<dynamic>? attachments;
  dynamic createdAt;
  dynamic updatedAt;
  int? v;
  dynamic status;

  RequestInfo({this.id, this.employeeId, this.employeeName, this.empId, this.companyId, this.branchId, this.policyId, this.requestType, this.subType, this.requestData, this.approvers, this.reason, this.attachments, this.createdAt, this.updatedAt, this.v, this.status});

  RequestInfo.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    employeeId = json["employeeId"];
    employeeName = json["employeeName"];
    empId = json["empId"];
    companyId = json["companyId"];
    branchId = json["branchId"];
    policyId = json["policyId"];
    requestType = json["requestType"];
    subType = json["subType"];
    requestData = json["requestData"] == null ? null : (json["requestData"] as List).map((e) => RequestData.fromJson(e)).toList();
    approvers = json["approvers"] == null ? null : (json["approvers"] as List).map((e) => Approvers.fromJson(e)).toList();
    reason = json["reason"];
    attachments = json["attachments"] ?? [];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
    status = json["status"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["employeeId"] = employeeId;
    _data["employeeName"] = employeeName;
    _data["empId"] = empId;
    _data["companyId"] = companyId;
    _data["branchId"] = branchId;
    _data["policyId"] = policyId;
    _data["requestType"] = requestType;
    _data["subType"] = subType;
    if(requestData != null) {
      _data["requestData"] = requestData?.map((e) => e.toJson()).toList();
    }
    if(approvers != null) {
      _data["approvers"] = approvers?.map((e) => e.toJson()).toList();
    }
    _data["reason"] = reason;
    if(attachments != null) {
      _data["attachments"] = attachments;
    }
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    _data["status"] = status;
    return _data;
  }
}
class Approvers {
  dynamic approverId;
  dynamic approverName;
  dynamic isRequired;
  dynamic status;
  dynamic timeStamps;
  dynamic comments;

  Approvers({this.approverId, this.approverName, this.isRequired, this.status, this.timeStamps, this.comments});

  Approvers.fromJson(Map<String, dynamic> json) {
    approverId = json["approverId"];
    approverName = json["approverName"];
    isRequired = json["isRequired"];
    status = json["status"];
    timeStamps = json["timeStamps"];
    comments = json["comments"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["approverId"] = approverId;
    _data["approverName"] = approverName;
    _data["isRequired"] = isRequired;
    _data["status"] = status;
    _data["timeStamps"] = timeStamps;
    _data["comments"] = comments;
    return _data;
  }
}

class RequestData {
  dynamic leaveType;
  dynamic startDate;
  dynamic endDate;
  dynamic duration;

  RequestData({this.leaveType, this.startDate, this.endDate, this.duration});

  RequestData.fromJson(Map<String, dynamic> json) {
    leaveType = json["leaveType"];
    startDate = json["startDate"];
    endDate = json["endDate"];
    duration = json["duration"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["leaveType"] = leaveType;
    _data["startDate"] = startDate;
    _data["endDate"] = endDate;
    _data["duration"] = duration;
    return _data;
  }
}

class ShiftInfo {
  dynamic timefrom;
  dynamic timeTo;
  dynamic shiftName;
  dynamic shiftType;

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