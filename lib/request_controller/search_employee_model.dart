class SearchEmployeeData {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  Data? data;

  SearchEmployeeData({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  SearchEmployeeData.fromJson(Map<String, dynamic> json) {
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
  List<Employees>? employees;

  Data({this.employees});

  Data.fromJson(Map<String, dynamic> json) {
    employees = json["employees"] == null ? null : (json["employees"] as List).map((e) => Employees.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if(employees != null) {
      _data["employees"] = employees?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Employees {
  dynamic id;
  dynamic userName;
  dynamic password;
  List<Email>? email;
  dynamic firstName;
  dynamic middleName;
  dynamic lastName;
  dynamic martialStatus;
  dynamic religion;
  Address? address;
  dynamic nic;
  IqamaNumber? iqamaNumber;
  Passport? passport;
  dynamic imigrationSatus;
  dynamic dob;
  dynamic age;
  List<PhoneNumber>? phoneNumber;
  dynamic gender;
  dynamic role;
  dynamic profession;
  dynamic nationality;
  dynamic profilePic;
  FamilyInfo? familyInfo;
  List<EducationInfo>? educationInfo;
  List<dynamic>? experienceBackground;
  List<BankingInfo>? bankingInfo;
  List<EmployeeInfo>? employeeInfo;
  SalaryInfo? salaryInfo;
  List<dynamic>? socialLinks;
  List<dynamic>? loanInfo;
  List<AssetsInfo>? assetsInfo;
  RemoteLocation? remoteLocation;
  List<dynamic>? contractInfo;
  List<DocumentsInfo>? documentsInfo;
  dynamic createdBy;
  dynamic branchId;
  dynamic departmentId;
  dynamic organizationId;
  dynamic createdAt;
  dynamic updatedAt;
  int? v;
  LeaveBalance? leaveBalance;
  ShiftInfo? shiftInfo;

  Employees({this.id, this.userName, this.password, this.email, this.firstName, this.middleName, this.lastName, this.martialStatus, this.religion, this.address, this.nic, this.iqamaNumber, this.passport, this.imigrationSatus, this.dob, this.age, this.phoneNumber, this.gender, this.role, this.profession, this.nationality, this.profilePic, this.familyInfo, this.educationInfo, this.experienceBackground, this.bankingInfo, this.employeeInfo, this.salaryInfo, this.socialLinks, this.loanInfo, this.assetsInfo, this.remoteLocation, this.contractInfo, this.documentsInfo, this.createdBy, this.branchId, this.departmentId, this.organizationId, this.createdAt, this.updatedAt, this.v, this.leaveBalance, this.shiftInfo});

  Employees.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    userName = json["userName"];
    password = json["password"];
    email = json["email"] == null ? null : (json["email"] as List).map((e) => Email.fromJson(e)).toList();
    firstName = json["firstName"];
    middleName = json["middleName"];
    lastName = json["lastName"];
    martialStatus = json["martialStatus"];
    religion = json["religion"];
    address = json["address"] == null ? null : Address.fromJson(json["address"]);
    nic = json["NIC"];
    iqamaNumber = json["iqamaNumber"] == null ? null : IqamaNumber.fromJson(json["iqamaNumber"]);
    passport = json["passport"] == null ? null : Passport.fromJson(json["passport"]);
    imigrationSatus = json["imigrationSatus"];
    dob = json["DOB"];
    age = json["age"];
    phoneNumber = json["phoneNumber"] == null ? null : (json["phoneNumber"] as List).map((e) => PhoneNumber.fromJson(e)).toList();
    gender = json["gender"];
    role = json["role"];
    profession = json["profession"];
    nationality = json["nationality"];
    profilePic = json["profilePic"];
    familyInfo = json["familyInfo"] == null ? null : FamilyInfo.fromJson(json["familyInfo"]);
    educationInfo = json["educationInfo"] == null ? null : (json["educationInfo"] as List).map((e) => EducationInfo.fromJson(e)).toList();
    experienceBackground = json["experienceBackground"] ?? [];
    bankingInfo = json["bankingInfo"] == null ? null : (json["bankingInfo"] as List).map((e) => BankingInfo.fromJson(e)).toList();
    employeeInfo = json["employeeInfo"] == null ? null : (json["employeeInfo"] as List).map((e) => EmployeeInfo.fromJson(e)).toList();
    salaryInfo = json["salaryInfo"] == null ? null : SalaryInfo.fromJson(json["salaryInfo"]);
    socialLinks = json["socialLinks"] ?? [];
    loanInfo = json["loanInfo"] ?? [];
    assetsInfo = json["assetsInfo"] == null ? null : (json["assetsInfo"] as List).map((e) => AssetsInfo.fromJson(e)).toList();
    remoteLocation = json["remoteLocation"] == null ? null : RemoteLocation.fromJson(json["remoteLocation"]);
    contractInfo = json["contractInfo"] ?? [];
    documentsInfo = json["documentsInfo"] == null ? null : (json["documentsInfo"] as List).map((e) => DocumentsInfo.fromJson(e)).toList();
    createdBy = json["createdBy"];
    branchId = json["branchId"];
    departmentId = json["departmentId"];
    organizationId = json["organizationId"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
    leaveBalance = json["leaveBalance"] == null ? null : LeaveBalance.fromJson(json["leaveBalance"]);
    shiftInfo = json["shiftInfo"] == null ? null : ShiftInfo.fromJson(json["shiftInfo"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["userName"] = userName;
    _data["password"] = password;
    if(email != null) {
      _data["email"] = email?.map((e) => e.toJson()).toList();
    }
    _data["firstName"] = firstName;
    _data["middleName"] = middleName;
    _data["lastName"] = lastName;
    _data["martialStatus"] = martialStatus;
    _data["religion"] = religion;
    if(address != null) {
      _data["address"] = address?.toJson();
    }
    _data["NIC"] = nic;
    if(iqamaNumber != null) {
      _data["iqamaNumber"] = iqamaNumber?.toJson();
    }
    if(passport != null) {
      _data["passport"] = passport?.toJson();
    }
    _data["imigrationSatus"] = imigrationSatus;
    _data["DOB"] = dob;
    _data["age"] = age;
    if(phoneNumber != null) {
      _data["phoneNumber"] = phoneNumber?.map((e) => e.toJson()).toList();
    }
    _data["gender"] = gender;
    _data["role"] = role;
    _data["profession"] = profession;
    _data["nationality"] = nationality;
    _data["profilePic"] = profilePic;
    if(familyInfo != null) {
      _data["familyInfo"] = familyInfo?.toJson();
    }
    if(educationInfo != null) {
      _data["educationInfo"] = educationInfo?.map((e) => e.toJson()).toList();
    }
    if(experienceBackground != null) {
      _data["experienceBackground"] = experienceBackground;
    }
    if(bankingInfo != null) {
      _data["bankingInfo"] = bankingInfo?.map((e) => e.toJson()).toList();
    }
    if(employeeInfo != null) {
      _data["employeeInfo"] = employeeInfo?.map((e) => e.toJson()).toList();
    }
    if(salaryInfo != null) {
      _data["salaryInfo"] = salaryInfo?.toJson();
    }
    if(socialLinks != null) {
      _data["socialLinks"] = socialLinks;
    }
    if(loanInfo != null) {
      _data["loanInfo"] = loanInfo;
    }
    if(assetsInfo != null) {
      _data["assetsInfo"] = assetsInfo?.map((e) => e.toJson()).toList();
    }
    if(remoteLocation != null) {
      _data["remoteLocation"] = remoteLocation?.toJson();
    }
    if(contractInfo != null) {
      _data["contractInfo"] = contractInfo;
    }
    if(documentsInfo != null) {
      _data["documentsInfo"] = documentsInfo?.map((e) => e.toJson()).toList();
    }
    _data["createdBy"] = createdBy;
    _data["branchId"] = branchId;
    _data["departmentId"] = departmentId;
    _data["organizationId"] = organizationId;
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    if(leaveBalance != null) {
      _data["leaveBalance"] = leaveBalance?.toJson();
    }
    if(shiftInfo != null) {
      _data["shiftInfo"] = shiftInfo?.toJson();
    }
    return _data;
  }
}

class ShiftInfo {
  dynamic shiftId;
  dynamic shiftType;
  dynamic shiftName;
  dynamic timeFrom;
  dynamic timeTo;

  ShiftInfo({this.shiftId, this.shiftType, this.shiftName, this.timeFrom, this.timeTo});

  ShiftInfo.fromJson(Map<String, dynamic> json) {
    shiftId = json["shiftId"];
    shiftType = json["shiftType"];
    shiftName = json["shiftName"];
    timeFrom = json["timeFrom"];
    timeTo = json["timeTo"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["shiftId"] = shiftId;
    _data["shiftType"] = shiftType;
    _data["shiftName"] = shiftName;
    _data["timeFrom"] = timeFrom;
    _data["timeTo"] = timeTo;
    return _data;
  }
}

class LeaveBalance {
  AnnualLeave? annualLeave;
  CasualLeave? casualLeave;
  ShortLeavesMonthlyBal? shortLeavesMonthlyBal;
  SickLeave? sickLeave;
  List<SpecialLeave>? specialLeave;

  LeaveBalance({this.annualLeave, this.casualLeave, this.shortLeavesMonthlyBal, this.sickLeave, this.specialLeave});

  LeaveBalance.fromJson(Map<String, dynamic> json) {
    annualLeave = json["annualLeave"] == null ? null : AnnualLeave.fromJson(json["annualLeave"]);
    casualLeave = json["casualLeave"] == null ? null : CasualLeave.fromJson(json["casualLeave"]);
    shortLeavesMonthlyBal = json["shortLeavesMonthlyBal"] == null ? null : ShortLeavesMonthlyBal.fromJson(json["shortLeavesMonthlyBal"]);
    sickLeave = json["sickLeave"] == null ? null : SickLeave.fromJson(json["sickLeave"]);
    specialLeave = json["specialLeave"] == null ? null : (json["specialLeave"] as List).map((e) => SpecialLeave.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if(annualLeave != null) {
      _data["annualLeave"] = annualLeave?.toJson();
    }
    if(casualLeave != null) {
      _data["casualLeave"] = casualLeave?.toJson();
    }
    if(shortLeavesMonthlyBal != null) {
      _data["shortLeavesMonthlyBal"] = shortLeavesMonthlyBal?.toJson();
    }
    if(sickLeave != null) {
      _data["sickLeave"] = sickLeave?.toJson();
    }
    if(specialLeave != null) {
      _data["specialLeave"] = specialLeave?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class SpecialLeave {
  dynamic leaveType;
  dynamic leaveName;
  dynamic entitlement;
  dynamic used;
  dynamic remaining;

  SpecialLeave({this.leaveType, this.leaveName, this.entitlement, this.used, this.remaining});

  SpecialLeave.fromJson(Map<String, dynamic> json) {
    leaveType = json["leaveType"];
    leaveName = json["leaveName"];
    entitlement = json["entitlement"];
    used = json["used"];
    remaining = json["remaining"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["leaveType"] = leaveType;
    _data["leaveName"] = leaveName;
    _data["entitlement"] = entitlement;
    _data["used"] = used;
    _data["remaining"] = remaining;
    return _data;
  }
}

class SickLeave {
  dynamic entitlement;
  dynamic remaining;
  dynamic used;

  SickLeave({this.entitlement, this.remaining, this.used});

  SickLeave.fromJson(Map<String, dynamic> json) {
    entitlement = json["entitlement"];
    remaining = json["remaining"];
    used = json["used"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["entitlement"] = entitlement;
    _data["remaining"] = remaining;
    _data["used"] = used;
    return _data;
  }
}

class ShortLeavesMonthlyBal {
  dynamic shortLeavesMinutes;

  ShortLeavesMonthlyBal({this.shortLeavesMinutes});

  ShortLeavesMonthlyBal.fromJson(Map<String, dynamic> json) {
    shortLeavesMinutes = json["shortLeavesMinutes"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["shortLeavesMinutes"] = shortLeavesMinutes;
    return _data;
  }
}

class CasualLeave {
  dynamic entitlement;
  dynamic remaining;
  dynamic used;

  CasualLeave({this.entitlement, this.remaining, this.used});

  CasualLeave.fromJson(Map<String, dynamic> json) {
    entitlement = json["entitlement"];
    remaining = json["remaining"];
    used = json["used"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["entitlement"] = entitlement;
    _data["remaining"] = remaining;
    _data["used"] = used;
    return _data;
  }
}

class AnnualLeave {
  dynamic currentMonth;
  dynamic entitlement;
  dynamic remaining;
  dynamic used;

  AnnualLeave({this.currentMonth, this.entitlement, this.remaining, this.used});

  AnnualLeave.fromJson(Map<String, dynamic> json) {
    currentMonth = json["currentMonth"];
    entitlement = json["entitlement"];
    remaining = json["remaining"];
    used = json["used"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["currentMonth"] = currentMonth;
    _data["entitlement"] = entitlement;
    _data["remaining"] = remaining;
    _data["used"] = used;
    return _data;
  }
}

class DocumentsInfo {
  dynamic docId;
  dynamic url;
  dynamic type;
  dynamic remarks;
  dynamic format;
  dynamic empId;
  dynamic expiration;
  dynamic size;
  dynamic createdAt;
  dynamic updatedAt;

  DocumentsInfo({this.docId, this.url, this.type, this.remarks, this.format, this.empId, this.expiration, this.size, this.createdAt, this.updatedAt});

  DocumentsInfo.fromJson(Map<String, dynamic> json) {
    docId = json["docId"];
    url = json["URL"];
    type = json["type"];
    remarks = json["remarks"];
    format = json["format"];
    empId = json["empId"];
    expiration = json["expiration"];
    size = json["size"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["docId"] = docId;
    _data["URL"] = url;
    _data["type"] = type;
    _data["remarks"] = remarks;
    _data["format"] = format;
    _data["empId"] = empId;
    _data["expiration"] = expiration;
    _data["size"] = size;
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    return _data;
  }
}

class RemoteLocation {
  dynamic isRemoteAttendance;
  dynamic remoteAttendanceLoc;
  dynamic lastLocation;
  dynamic lastLocationUpdatedAt;

  RemoteLocation({this.isRemoteAttendance, this.remoteAttendanceLoc, this.lastLocation, this.lastLocationUpdatedAt});

  RemoteLocation.fromJson(Map<String, dynamic> json) {
    isRemoteAttendance = json["isRemoteAttendance"];
    remoteAttendanceLoc = json["remoteAttendanceLoc"];
    lastLocation = json["lastLocation"];
    lastLocationUpdatedAt = json["lastLocationUpdatedAt"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["isRemoteAttendance"] = isRemoteAttendance;
    _data["remoteAttendanceLoc"] = remoteAttendanceLoc;
    _data["lastLocation"] = lastLocation;
    _data["lastLocationUpdatedAt"] = lastLocationUpdatedAt;
    return _data;
  }
}

class AssetsInfo {
  dynamic assetId;
  dynamic assetName;
  dynamic assetType;
  dynamic issueDateFrom;
  dynamic issueDateTo;

  AssetsInfo({this.assetId, this.assetName, this.assetType, this.issueDateFrom, this.issueDateTo});

  AssetsInfo.fromJson(Map<String, dynamic> json) {
    assetId = json["assetId"];
    assetName = json["assetName"];
    assetType = json["assetType"];
    issueDateFrom = json["issueDateFrom"];
    issueDateTo = json["issueDateTo"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["assetId"] = assetId;
    _data["assetName"] = assetName;
    _data["assetType"] = assetType;
    _data["issueDateFrom"] = issueDateFrom;
    _data["issueDateTo"] = issueDateTo;
    return _data;
  }
}

class SalaryInfo {
  dynamic baseSalary;
  dynamic currency;
  dynamic timeCyclePeriod;
  List<dynamic>? deductions;
  TaxInfo? taxInfo;
  dynamic allowanceContribution;
  dynamic netSalary;

  SalaryInfo({this.baseSalary, this.currency, this.timeCyclePeriod, this.deductions, this.taxInfo, this.allowanceContribution, this.netSalary});

  SalaryInfo.fromJson(Map<String, dynamic> json) {
    baseSalary = json["baseSalary"];
    currency = json["currency"];
    timeCyclePeriod = json["timeCycle_Period"];
    deductions = json["deductions"] ?? [];
    taxInfo = json["taxInfo"] == null ? null : TaxInfo.fromJson(json["taxInfo"]);
    allowanceContribution = json["allowanceContribution"];
    netSalary = json["netSalary"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["baseSalary"] = baseSalary;
    _data["currency"] = currency;
    _data["timeCycle_Period"] = timeCyclePeriod;
    if(deductions != null) {
      _data["deductions"] = deductions;
    }
    if(taxInfo != null) {
      _data["taxInfo"] = taxInfo?.toJson();
    }
    _data["allowanceContribution"] = allowanceContribution;
    _data["netSalary"] = netSalary;
    return _data;
  }
}

class TaxInfo {
  dynamic texPercentage;
  dynamic deductableAmount;
  dynamic timeCycle;

  TaxInfo({this.texPercentage, this.deductableAmount, this.timeCycle});

  TaxInfo.fromJson(Map<String, dynamic> json) {
    texPercentage = json["texPercentage"];
    deductableAmount = json["deductableAmount"];
    timeCycle = json["timeCycle"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["texPercentage"] = texPercentage;
    _data["deductableAmount"] = deductableAmount;
    _data["timeCycle"] = timeCycle;
    return _data;
  }
}

class EmployeeInfo {
  dynamic depId;
  dynamic depName;
  dynamic jobTitle;
  dynamic jobDescription;
  dynamic reportingManager;
  dynamic jobRank;
  dynamic designation;
  dynamic grade;
  dynamic workDomain;
  dynamic location;
  dynamic employeeStatus;
  dynamic employeeType;
  dynamic employeeShift;
  dynamic joiningDate;
  dynamic leavingDate;
  dynamic hiringDate;
  dynamic noticePeriod;
  dynamic empId;
  dynamic empSignature;

  EmployeeInfo({this.depId, this.depName, this.jobTitle, this.jobDescription, this.reportingManager, this.jobRank, this.designation, this.grade, this.workDomain, this.location, this.employeeStatus, this.employeeType, this.employeeShift, this.joiningDate, this.leavingDate, this.hiringDate, this.noticePeriod, this.empId, this.empSignature});

  EmployeeInfo.fromJson(Map<String, dynamic> json) {
    depId = json["depId"];
    depName = json["depName"];
    jobTitle = json["jobTitle"];
    jobDescription = json["jobDescription"];
    reportingManager = json["reportingManager"];
    jobRank = json["jobRank"];
    designation = json["designation"];
    grade = json["grade"];
    workDomain = json["workDomain"];
    location = json["location"];
    employeeStatus = json["employeeStatus"];
    employeeType = json["employeeType"];
    employeeShift = json["employeeShift"];
    joiningDate = json["joiningDate"];
    leavingDate = json["leavingDate"];
    hiringDate = json["hiringDate"];
    noticePeriod = json["noticePeriod"];
    empId = json["empId"];
    empSignature = json["empSignature"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["depId"] = depId;
    _data["depName"] = depName;
    _data["jobTitle"] = jobTitle;
    _data["jobDescription"] = jobDescription;
    _data["reportingManager"] = reportingManager;
    _data["jobRank"] = jobRank;
    _data["designation"] = designation;
    _data["grade"] = grade;
    _data["workDomain"] = workDomain;
    _data["location"] = location;
    _data["employeeStatus"] = employeeStatus;
    _data["employeeType"] = employeeType;
    _data["employeeShift"] = employeeShift;
    _data["joiningDate"] = joiningDate;
    _data["leavingDate"] = leavingDate;
    _data["hiringDate"] = hiringDate;
    _data["noticePeriod"] = noticePeriod;
    _data["empId"] = empId;
    _data["empSignature"] = empSignature;
    return _data;
  }
}

class BankingInfo {
  dynamic title;
  dynamic accountNumber;
  dynamic branchCode;
  dynamic accountType;
  dynamic country;
  dynamic empSwiftCode;
  dynamic bankName;

  BankingInfo({this.title, this.accountNumber, this.branchCode, this.accountType, this.country, this.empSwiftCode, this.bankName});

  BankingInfo.fromJson(Map<String, dynamic> json) {
    title = json["title"];
    accountNumber = json["accountNumber"];
    branchCode = json["branchCode"];
    accountType = json["accountType"];
    country = json["country"];
    empSwiftCode = json["empSwiftCode"];
    bankName = json["bankName"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["title"] = title;
    _data["accountNumber"] = accountNumber;
    _data["branchCode"] = branchCode;
    _data["accountType"] = accountType;
    _data["country"] = country;
    _data["empSwiftCode"] = empSwiftCode;
    _data["bankName"] = bankName;
    return _data;
  }
}

class EducationInfo {
  dynamic degreeName;
  dynamic degreeType;
  dynamic fieldofStudy;
  dynamic institute;
  dynamic from;
  dynamic to;
  dynamic results;

  EducationInfo({this.degreeName, this.degreeType, this.fieldofStudy, this.institute, this.from, this.to, this.results});

  EducationInfo.fromJson(Map<String, dynamic> json) {
    degreeName = json["degreeName"];
    degreeType = json["degreeType"];
    fieldofStudy = json["fieldofStudy"];
    institute = json["institute"];
    from = json["from"];
    to = json["to"];
    results = json["results"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["degreeName"] = degreeName;
    _data["degreeType"] = degreeType;
    _data["fieldofStudy"] = fieldofStudy;
    _data["institute"] = institute;
    _data["from"] = from;
    _data["to"] = to;
    _data["results"] = results;
    return _data;
  }
}

class FamilyInfo {
  dynamic fatherName;
  dynamic motherName;
  FamilyAddress? familyAddress;
  dynamic familyContactNumber;
  List<EmergencyContactInfo>? emergencyContactInfo;

  FamilyInfo({this.fatherName, this.motherName, this.familyAddress, this.familyContactNumber, this.emergencyContactInfo});

  FamilyInfo.fromJson(Map<String, dynamic> json) {
    fatherName = json["fatherName"];
    motherName = json["motherName"];
    familyAddress = json["familyAddress"] == null ? null : FamilyAddress.fromJson(json["familyAddress"]);
    familyContactNumber = json["familyContactNumber"];
    emergencyContactInfo = json["emergencyContactInfo"] == null ? null : (json["emergencyContactInfo"] as List).map((e) => EmergencyContactInfo.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["fatherName"] = fatherName;
    _data["motherName"] = motherName;
    if(familyAddress != null) {
      _data["familyAddress"] = familyAddress?.toJson();
    }
    _data["familyContactNumber"] = familyContactNumber;
    if(emergencyContactInfo != null) {
      _data["emergencyContactInfo"] = emergencyContactInfo?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class EmergencyContactInfo {
  dynamic relationName;
  dynamic relationType;
  dynamic relationContactNumber;
  dynamic relationAddress;

  EmergencyContactInfo({this.relationName, this.relationType, this.relationContactNumber, this.relationAddress});

  EmergencyContactInfo.fromJson(Map<String, dynamic> json) {
    relationName = json["relationName"];
    relationType = json["relationType"];
    relationContactNumber = json["relationContactNumber"];
    relationAddress = json["relationAddress"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["relationName"] = relationName;
    _data["relationType"] = relationType;
    _data["relationContactNumber"] = relationContactNumber;
    _data["relationAddress"] = relationAddress;
    return _data;
  }
}

class FamilyAddress {
  dynamic streetAddress;
  dynamic city;
  dynamic country;

  FamilyAddress({this.streetAddress, this.city, this.country});

  FamilyAddress.fromJson(Map<String, dynamic> json) {
    streetAddress = json["streetAddress"];
    city = json["city"];
    country = json["country"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["streetAddress"] = streetAddress;
    _data["city"] = city;
    _data["country"] = country;
    return _data;
  }
}

class PhoneNumber {
  dynamic mobileNumber;
  dynamic landlineNumber;

  PhoneNumber({this.mobileNumber, this.landlineNumber});

  PhoneNumber.fromJson(Map<String, dynamic> json) {
    mobileNumber = json["mobileNumber"];
    landlineNumber = json["landlineNumber"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["mobileNumber"] = mobileNumber;
    _data["landlineNumber"] = landlineNumber;
    return _data;
  }
}

class Passport {
  dynamic id;
  dynamic issueDate;
  dynamic expiryDate;

  Passport({this.id, this.issueDate, this.expiryDate});

  Passport.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    issueDate = json["issueDate"];
    expiryDate = json["expiryDate"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["issueDate"] = issueDate;
    _data["expiryDate"] = expiryDate;
    return _data;
  }
}

class IqamaNumber {
  dynamic id;
  dynamic issueDate;
  dynamic expiryDate;

  IqamaNumber({this.id, this.issueDate, this.expiryDate});

  IqamaNumber.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    issueDate = json["issueDate"];
    expiryDate = json["expiryDate"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["issueDate"] = issueDate;
    _data["expiryDate"] = expiryDate;
    return _data;
  }
}

class Address {
  dynamic streetAddress;
  dynamic city;
  dynamic country;

  Address({this.streetAddress, this.city, this.country});

  Address.fromJson(Map<String, dynamic> json) {
    streetAddress = json["streetAddress"];
    city = json["city"];
    country = json["country"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["streetAddress"] = streetAddress;
    _data["city"] = city;
    _data["country"] = country;
    return _data;
  }
}

class Email {
  dynamic workEmail;

  Email({this.workEmail});

  Email.fromJson(Map<String, dynamic> json) {
    workEmail = json["workEmail"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["workEmail"] = workEmail;
    return _data;
  }
}