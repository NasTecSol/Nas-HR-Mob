
class TimeTableShiftModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  List<Data>? data;

  TimeTableShiftModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  TimeTableShiftModel.fromJson(Map<String, dynamic> json) {
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
  String? companyId;
  String? branchId;
  List<TimeTableShifts>? shifts;

  Data({this.id, this.companyId, this.branchId, this.shifts});

  Data.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    companyId = json["companyId"];
    branchId = json["branchId"];
    shifts = json["shifts"] == null ? null : (json["shifts"] as List).map((e) => TimeTableShifts.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["companyId"] = companyId;
    _data["branchId"] = branchId;
    if(shifts != null) {
      _data["shifts"] = shifts?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class TimeTableShifts {
  String? employeeId;
  String? employeeName;
  String? empId;
  String? role;
  String? employeeShift;
  List<dynamic>? shiftRules;
  List<ShiftDates>? shiftDates;

  TimeTableShifts({this.employeeId, this.employeeName, this.empId, this.role, this.employeeShift, this.shiftRules, this.shiftDates});

  TimeTableShifts.fromJson(Map<String, dynamic> json) {
    employeeId = json["employeeId"];
    employeeName = json["employeeName"];
    empId = json["empId"];
    role = json["role"];
    employeeShift = json["employeeShift"];
    shiftRules = json["shiftRules"] ?? [];
    shiftDates = json["shiftDates"] == null ? null : (json["shiftDates"] as List).map((e) => ShiftDates.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["employeeId"] = employeeId;
    _data["employeeName"] = employeeName;
    _data["empId"] = empId;
    _data["role"] = role;
    _data["employeeShift"] = employeeShift;
    if(shiftRules != null) {
      _data["shiftRules"] = shiftRules;
    }
    if(shiftDates != null) {
      _data["shiftDates"] = shiftDates?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class ShiftDates {
  String? date;
  List<Slots>? slots;

  ShiftDates({this.date, this.slots});

  ShiftDates.fromJson(Map<String, dynamic> json) {
    date = json["date"];
    slots = json["slots"] == null ? null : (json["slots"] as List).map((e) => Slots.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["date"] = date;
    if(slots != null) {
      _data["slots"] = slots?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Slots {
  String? start;
  String? end;
  String? type;
  String? color;

  Slots({this.start, this.end, this.type, this.color});

  Slots.fromJson(Map<String, dynamic> json) {
    start = json["start"];
    end = json["end"];
    type = json["type"];
    color = json["color"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["start"] = start;
    _data["end"] = end;
    _data["type"] = type;
    _data["color"] = color;
    return _data;
  }
}