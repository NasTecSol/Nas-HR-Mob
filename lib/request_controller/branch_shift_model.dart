class BranchShiftModel {
  dynamic statusCode;
  dynamic statusMessage;
  dynamic errorMessage;
  Data? data;

  BranchShiftModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  BranchShiftModel.fromJson(Map<String, dynamic> json) {
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
  Branch? branch;
  List<EmployeeShifts>? employeeShifts;

  Data({this.branch, this.employeeShifts});

  Data.fromJson(Map<String, dynamic> json) {
    branch = json["branch"] == null ? null : Branch.fromJson(json["branch"]);
    employeeShifts = json["employeeShifts"] == null ? null : (json["employeeShifts"] as List).map((e) => EmployeeShifts.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if(branch != null) {
      _data["branch"] = branch?.toJson();
    }
    if(employeeShifts != null) {
      _data["employeeShifts"] = employeeShifts?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class EmployeeShifts {
  dynamic employeeId;
  dynamic employeeShift;

  EmployeeShifts({this.employeeId, this.employeeShift});

  EmployeeShifts.fromJson(Map<String, dynamic> json) {
    employeeId = json["employeeId"];
    employeeShift = json["employeeShift"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["employeeId"] = employeeId;
    _data["employeeShift"] = employeeShift;
    return _data;
  }
}

class Branch {
  dynamic id;
  dynamic parentCompanyId;
  dynamic branchCompanyId;
  List<DepartmentDetails>? departmentDetails;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic v;
  dynamic branchName;

  Branch({this.id, this.parentCompanyId, this.branchCompanyId, this.departmentDetails, this.createdAt, this.updatedAt, this.v, this.branchName});

  Branch.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    parentCompanyId = json["parentCompanyId"];
    branchCompanyId = json["branchCompanyId"];
    departmentDetails = json["departmentDetails"] == null ? null : (json["departmentDetails"] as List).map((e) => DepartmentDetails.fromJson(e)).toList();
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
    branchName = json["branchName"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["parentCompanyId"] = parentCompanyId;
    _data["branchCompanyId"] = branchCompanyId;
    if(departmentDetails != null) {
      _data["departmentDetails"] = departmentDetails?.map((e) => e.toJson()).toList();
    }
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    _data["branchName"] = branchName;
    return _data;
  }
}

class DepartmentDetails {
  List<Departments>? departments;
  List<Shifts>? shifts;

  DepartmentDetails({this.departments, this.shifts});

  DepartmentDetails.fromJson(Map<String, dynamic> json) {
    departments = json["departments"] == null ? null : (json["departments"] as List).map((e) => Departments.fromJson(e)).toList();
    shifts = json["shifts"] == null ? null : (json["shifts"] as List).map((e) => Shifts.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if(departments != null) {
      _data["departments"] = departments?.map((e) => e.toJson()).toList();
    }
    if(shifts != null) {
      _data["shifts"] = shifts?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Shifts {
  dynamic shiftType;
  dynamic shiftName;
  dynamic timeFrom;
  dynamic timeTo;
  dynamic startingFrom;
  dynamic totalHours;
  dynamic allowedBreak;

  Shifts({this.shiftType, this.shiftName, this.timeFrom, this.timeTo, this.startingFrom, this.totalHours, this.allowedBreak});

  Shifts.fromJson(Map<String, dynamic> json) {
    shiftType = json["shiftType"];
    shiftName = json["shiftName"];
    timeFrom = json["timeFrom"];
    timeTo = json["timeTo"];
    startingFrom = json["startingFrom"];
    totalHours = json["totalHours"];
    allowedBreak = json["allowedBreak"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["shiftType"] = shiftType;
    _data["shiftName"] = shiftName;
    _data["timeFrom"] = timeFrom;
    _data["timeTo"] = timeTo;
    _data["startingFrom"] = startingFrom;
    _data["totalHours"] = totalHours;
    _data["allowedBreak"] = allowedBreak;
    return _data;
  }
}

class Departments {
  dynamic departmentId;
  dynamic departmentName;
  List<Supervisors>? supervisors;
  List<Teams>? teams;

  Departments({this.departmentId, this.departmentName, this.supervisors, this.teams});

  Departments.fromJson(Map<String, dynamic> json) {
    departmentId = json["departmentId"];
    departmentName = json["departmentName"];
    supervisors = json["supervisors"] == null ? null : (json["supervisors"] as List).map((e) => Supervisors.fromJson(e)).toList();
    teams = json["teams"] == null ? null : (json["teams"] as List).map((e) => Teams.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["departmentId"] = departmentId;
    _data["departmentName"] = departmentName;
    if(supervisors != null) {
      _data["supervisors"] = supervisors?.map((e) => e.toJson()).toList();
    }
    if(teams != null) {
      _data["teams"] = teams?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Teams {
  dynamic teamId;
  List<TeamData>? teamData;

  Teams({this.teamId, this.teamData});

  Teams.fromJson(Map<String, dynamic> json) {
    teamId = json["teamId"];
    teamData = json["teamData"] == null ? null : (json["teamData"] as List).map((e) => TeamData.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["teamId"] = teamId;
    if(teamData != null) {
      _data["teamData"] = teamData?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class TeamData {
  dynamic empId;
  dynamic employeeId;
  dynamic userName;
  dynamic designation;
  dynamic grade;

  TeamData({this.empId, this.employeeId, this.userName, this.designation, this.grade});

  TeamData.fromJson(Map<String, dynamic> json) {
    empId = json["empId"];
    employeeId = json["employeeId"];
    userName = json["userName"];
    designation = json["designation"];
    grade = json["grade"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["empId"] = empId;
    _data["employeeId"] = employeeId;
    _data["userName"] = userName;
    _data["designation"] = designation;
    _data["grade"] = grade;
    return _data;
  }
}

class Supervisors {
  dynamic empId;
  dynamic employeeId;
  dynamic userName;
  dynamic designation;
  dynamic grade;
  dynamic teamId;

  Supervisors({this.empId, this.employeeId, this.userName, this.designation, this.grade, this.teamId});

  Supervisors.fromJson(Map<String, dynamic> json) {
    empId = json["empId"];
    employeeId = json["employeeId"];
    userName = json["userName"];
    designation = json["designation"];
    grade = json["grade"];
    teamId = json["teamId"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["empId"] = empId;
    _data["employeeId"] = employeeId;
    _data["userName"] = userName;
    _data["designation"] = designation;
    _data["grade"] = grade;
    _data["teamId"] = teamId;
    return _data;
  }
}