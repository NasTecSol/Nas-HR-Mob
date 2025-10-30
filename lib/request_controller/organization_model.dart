class OrganizationModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  Data? data;

  OrganizationModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  OrganizationModel.fromJson(Map<String, dynamic> json) {
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
  dynamic id;
  dynamic organizationName;
  dynamic organizationTitle;
  dynamic licenseId;
  dynamic country;
  dynamic address;
  dynamic settings;
  List<Companies>? companies;

  Data({this.id, this.organizationName, this.organizationTitle, this.licenseId, this.country, this.address, this.settings, this.companies});

  Data.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    organizationName = json["organizationName"];
    organizationTitle = json["organizationTitle"];
    licenseId = json["licenseId"];
    country = json["country"];
    address = json["address"];
    settings = json["settings"];
    companies = json["companies"] == null ? null : (json["companies"] as List).map((e) => Companies.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["organizationName"] = organizationName;
    _data["organizationTitle"] = organizationTitle;
    _data["licenseId"] = licenseId;
    _data["country"] = country;
    _data["address"] = address;
    _data["settings"] = settings;
    if(companies != null) {
      _data["companies"] = companies?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Companies {
  dynamic id;
  dynamic name;
  dynamic title;
  dynamic city;
  dynamic country;
  dynamic address;
  dynamic logo;
  dynamic licenseId;
  dynamic organizationId;
  List<Branches>? branches;
  dynamic createdAt;
  dynamic updatedAt;

  Companies({this.id, this.name, this.title, this.city, this.country, this.address, this.logo, this.licenseId, this.organizationId, this.branches, this.createdAt, this.updatedAt});

  Companies.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    name = json["name"];
    title = json["title"];
    city = json["city"];
    country = json["country"];
    address = json["address"];
    logo = json["logo"];
    licenseId = json["licenseId"];
    organizationId = json["organizationId"];
    branches = json["branches"] == null ? null : (json["branches"] as List).map((e) => Branches.fromJson(e)).toList();
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["name"] = name;
    _data["title"] = title;
    _data["city"] = city;
    _data["country"] = country;
    _data["address"] = address;
    _data["logo"] = logo;
    _data["licenseId"] = licenseId;
    _data["organizationId"] = organizationId;
    if(branches != null) {
      _data["branches"] = branches?.map((e) => e.toJson()).toList();
    }
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    return _data;
  }
}

class Branches {
  dynamic id;
  dynamic branchName;
  dynamic branchCRno;
  dynamic branchAddress;
  dynamic branchLogo;
  List<Departments>? departments;
  List<Shifts>? shifts;
  dynamic createdAt;
  dynamic updatedAt;

  Branches({this.id, this.branchName, this.branchCRno, this.branchAddress, this.branchLogo, this.departments, this.shifts, this.createdAt, this.updatedAt});

  Branches.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    branchName = json["branchName"];
    branchCRno = json["branchCRno"];
    branchAddress = json["branchAddress"];
    branchLogo = json["branchLogo"];
    departments = json["departments"] == null ? null : (json["departments"] as List).map((e) => Departments.fromJson(e)).toList();
    shifts = json["shifts"] == null ? null : (json["shifts"] as List).map((e) => Shifts.fromJson(e)).toList();
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["branchName"] = branchName;
    _data["branchCRno"] = branchCRno;
    _data["branchAddress"] = branchAddress;
    _data["branchLogo"] = branchLogo;
    if(departments != null) {
      _data["departments"] = departments?.map((e) => e.toJson()).toList();
    }
    if(shifts != null) {
      _data["shifts"] = shifts?.map((e) => e.toJson()).toList();
    }
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    return _data;
  }
}

class Shifts {
  dynamic shiftId;
  dynamic shiftName;
  dynamic shiftType;
  dynamic startingFrom;
  dynamic timeFrom;
  dynamic timeTo;
  dynamic checkInStarts;
  dynamic checkInEnds;
  dynamic checkOutStarts;
  dynamic checkOutEnds;
  dynamic gracePeriod;
  dynamic totalHours;
  dynamic allowedBreak;
  bool? isMidNightShift;
  bool? isActive;
  WorkingDays? workingDays;

  Shifts({this.shiftId, this.shiftName, this.shiftType, this.startingFrom, this.timeFrom, this.timeTo, this.checkInStarts, this.checkInEnds, this.checkOutStarts, this.checkOutEnds, this.gracePeriod, this.totalHours, this.allowedBreak, this.isMidNightShift, this.isActive, this.workingDays});

  Shifts.fromJson(Map<String, dynamic> json) {
    shiftId = json["shiftId"];
    shiftName = json["shiftName"];
    shiftType = json["shiftType"];
    startingFrom = json["startingFrom"];
    timeFrom = json["timeFrom"];
    timeTo = json["timeTo"];
    checkInStarts = json["checkInStarts"];
    checkInEnds = json["checkInEnds"];
    checkOutStarts = json["checkOutStarts"];
    checkOutEnds = json["checkOutEnds"];
    gracePeriod = json["gracePeriod"];
    totalHours = json["totalHours"];
    allowedBreak = json["allowedBreak"];
    isMidNightShift = json["isMidNightShift"];
    isActive = json["isActive"];
    workingDays = json["workingDays"] == null ? null : WorkingDays.fromJson(json["workingDays"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["shiftId"] = shiftId;
    _data["shiftName"] = shiftName;
    _data["shiftType"] = shiftType;
    _data["startingFrom"] = startingFrom;
    _data["timeFrom"] = timeFrom;
    _data["timeTo"] = timeTo;
    _data["checkInStarts"] = checkInStarts;
    _data["checkInEnds"] = checkInEnds;
    _data["checkOutStarts"] = checkOutStarts;
    _data["checkOutEnds"] = checkOutEnds;
    _data["gracePeriod"] = gracePeriod;
    _data["totalHours"] = totalHours;
    _data["allowedBreak"] = allowedBreak;
    _data["isMidNightShift"] = isMidNightShift;
    _data["isActive"] = isActive;
    if(workingDays != null) {
      _data["workingDays"] = workingDays?.toJson();
    }
    return _data;
  }
}

class WorkingDays {
  bool? monday;
  bool? tuesday;
  bool? wednesday;
  bool? thursday;
  bool? friday;
  bool? saturday;
  bool? sunday;

  WorkingDays({this.monday, this.tuesday, this.wednesday, this.thursday, this.friday, this.saturday, this.sunday});

  WorkingDays.fromJson(Map<String, dynamic> json) {
    monday = json["monday"];
    tuesday = json["tuesday"];
    wednesday = json["wednesday"];
    thursday = json["thursday"];
    friday = json["friday"];
    saturday = json["saturday"];
    sunday = json["sunday"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["monday"] = monday;
    _data["tuesday"] = tuesday;
    _data["wednesday"] = wednesday;
    _data["thursday"] = thursday;
    _data["friday"] = friday;
    _data["saturday"] = saturday;
    _data["sunday"] = sunday;
    return _data;
  }
}

class Departments {
  dynamic departmentId;
  dynamic departmentName;
  List<dynamic>? supervisors;
  List<dynamic>? teams;

  Departments({this.departmentId, this.departmentName, this.supervisors, this.teams});

  Departments.fromJson(Map<String, dynamic> json) {
    departmentId = json["departmentId"];
    departmentName = json["departmentName"];
    supervisors = json["supervisors"] ?? [];
    teams = json["teams"] ?? [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
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