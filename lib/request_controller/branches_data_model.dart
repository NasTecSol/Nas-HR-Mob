class BranchesDataModel {
  dynamic statusCode;
  dynamic statusMessage;
  dynamic errorMessage;
  List<Data>? data;

  BranchesDataModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  BranchesDataModel.fromJson(Map<dynamic, dynamic> json) {
    statusCode = json["statusCode"];
    statusMessage = json["statusMessage"];
    errorMessage = json["errorMessage"];
    data = json["data"] == null ? null : (json["data"] as List).map((e) => Data.fromJson(e)).toList();
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> _data = <dynamic, dynamic>{};
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
  dynamic id;
  dynamic parentCompanyId;
  dynamic branchCompanyId;
  dynamic branchName;
  dynamic branchCRno;
  dynamic branchAddress;
  dynamic branchLogo;
  List<DepartmentDetails>? departmentDetails;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic v;

  Data({this.id, this.parentCompanyId, this.branchCompanyId, this.branchName, this.branchCRno, this.branchAddress, this.branchLogo, this.departmentDetails, this.createdAt, this.updatedAt, this.v});

  Data.fromJson(Map<dynamic, dynamic> json) {
    id = json["_id"];
    parentCompanyId = json["parentCompanyId"];
    branchCompanyId = json["branchCompanyId"];
    branchName = json["branchName"];
    branchCRno = json["branchCRno"];
    branchAddress = json["branchAddress"];
    branchLogo = json["branchLogo"];
    departmentDetails = json["departmentDetails"] == null ? null : (json["departmentDetails"] as List).map((e) => DepartmentDetails.fromJson(e)).toList();
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> _data = <dynamic, dynamic>{};
    _data["_id"] = id;
    _data["parentCompanyId"] = parentCompanyId;
    _data["branchCompanyId"] = branchCompanyId;
    _data["branchName"] = branchName;
    _data["branchCRno"] = branchCRno;
    _data["branchAddress"] = branchAddress;
    _data["branchLogo"] = branchLogo;
    if(departmentDetails != null) {
      _data["departmentDetails"] = departmentDetails?.map((e) => e.toJson()).toList();
    }
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    return _data;
  }
}

class DepartmentDetails {
  List<Departments>? departments;
  List<Shifts>? shifts;

  DepartmentDetails({this.departments, this.shifts});

  DepartmentDetails.fromJson(Map<dynamic, dynamic> json) {
    departments = json["departments"] == null ? null : (json["departments"] as List).map((e) => Departments.fromJson(e)).toList();
    shifts = json["shifts"] == null ? null : (json["shifts"] as List).map((e) => Shifts.fromJson(e)).toList();
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> _data = <dynamic, dynamic>{};
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

  Shifts.fromJson(Map<dynamic, dynamic> json) {
    shiftType = json["shiftType"];
    shiftName = json["shiftName"];
    timeFrom = json["timeFrom"];
    timeTo = json["timeTo"];
    startingFrom = json["startingFrom"];
    totalHours = json["totalHours"];
    allowedBreak = json["allowedBreak"];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> _data = <dynamic, dynamic>{};
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
  List<dynamic>? supervisors;
  List<dynamic>? teams;

  Departments({this.departmentId, this.departmentName, this.supervisors, this.teams});

  Departments.fromJson(Map<dynamic, dynamic> json) {
    departmentId = json["departmentId"];
    departmentName = json["departmentName"];
    supervisors = json["supervisors"] ?? [];
    teams = json["teams"] ?? [];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> _data = <dynamic, dynamic>{};
    _data["departmentId"] = departmentId;
    _data["departmentName"] = departmentName;
    if(supervisors != null) {
      _data["supervisors"] = supervisors;
    }
    if(teams != null) {
      _data["teams"] = teams;
    }
    return _data;
  }
}