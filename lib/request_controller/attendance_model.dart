
class AttendanceData {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  List<Data>? data;

  AttendanceData({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  AttendanceData.fromJson(Map<String, dynamic> json) {
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
  String? empId;
  String? name;
  String? companyId;
  String? branchId;
  String? date;
  String? clockInTime;
  String? clockOutTime;
  int? totalHoursWorked;
  String? location;
  String? status;
  List<dynamic>? breaksTaken;
  int? breakTime;
  int? lateMinutes;
  List<dynamic>? penalties;
  dynamic leaveDetails;
  String? shift;
  int? workingHoursPerday;
  int? earlyCheckOut;
  String? remarks;
  String? createdAt;
  String? updatedAt;
  int? v;

  Data({this.id, this.employeeId, this.empId, this.name, this.companyId, this.branchId, this.date, this.clockInTime, this.clockOutTime, this.totalHoursWorked, this.location, this.status, this.breaksTaken, this.breakTime, this.lateMinutes, this.penalties, this.leaveDetails, this.shift, this.workingHoursPerday, this.earlyCheckOut, this.remarks, this.createdAt, this.updatedAt, this.v});

  Data.fromJson(Map<String, dynamic> json) {
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
    breaksTaken = json["breaksTaken"] ?? [];
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
    if(breaksTaken != null) {
      _data["breaksTaken"] = breaksTaken;
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