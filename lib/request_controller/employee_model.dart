class EmployeeData {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  List<Data> data;

  EmployeeData({
    this.statusCode,
    this.statusMessage,
    this.errorMessage,
    List<Data>? data,
  }) : data = data ?? [];

  factory EmployeeData.fromJson(Map<String, dynamic> json) {
    final rawData = json["data"];

    List<Data> parsedData = [];

    if (rawData is List) {
      parsedData = rawData
          .map((e) => Data.fromJson(e))
          .toList();
    }
    else if (rawData is Map<String, dynamic>) {
      parsedData = [Data.fromJson(rawData)];
    }

    return EmployeeData(
      statusCode: json["statusCode"],
      statusMessage: json["statusMessage"],
      errorMessage: json["errorMessage"],
      data: parsedData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "statusCode": statusCode,
      "statusMessage": statusMessage,
      "errorMessage": errorMessage,
      "data": data.map((e) => e.toJson()).toList(),
    };
  }
}
class Data {
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
  List<ExperienceBackground>? experienceBackground;
  List<BankingInfo>? bankingInfo;
  List<EmployeeInfo>? employeeInfo;
  SalaryInfo? salaryInfo;
  List<SocialLinks>? socialLinks;
  List<LoanInfo>? loanInfo;
  List<dynamic>? assetsInfo;
  List<Approvals>? approvals;
  List<ContractInfo>? contractInfo;
  List<dynamic>? documentsInfo; // Dynamic list for documents handling
  dynamic createdBy;
  dynamic branchId;
  dynamic departmentId;
  dynamic organizationId;
  int? v;
  LeaveBalance? leaveBalance;
  ShiftInfo? shiftInfo;

  Data(
      {this.id,
        this.userName,
        this.password,
        this.email,
        this.firstName,
        this.middleName,
        this.lastName,
        this.martialStatus,
        this.religion,
        this.address,
        this.nic,
        this.iqamaNumber,
        this.passport,
        this.imigrationSatus,
        this.dob,
        this.age,
        this.phoneNumber,
        this.gender,
        this.role,
        this.profession,
        this.nationality,
        this.profilePic,
        this.familyInfo,
        this.educationInfo,
        this.experienceBackground,
        this.bankingInfo,
        this.employeeInfo,
        this.salaryInfo,
        this.socialLinks,
        this.loanInfo,
        this.assetsInfo,
        this.approvals,
        this.contractInfo,
        this.documentsInfo, // Handle dynamic data here
        this.createdBy,
        this.branchId,
        this.departmentId,
        this.organizationId,
        this.v,
        this.leaveBalance,
        this.shiftInfo
      });

  Data.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    userName = json["userName"];
    password = json["password"];
    email = json["email"] == null
        ? null
        : (json["email"] as List).map((e) => Email.fromJson(e)).toList();
    firstName = json["firstName"];
    middleName = json["middleName"];
    lastName = json["lastName"];
    martialStatus = json["martialStatus"];
    religion = json["religion"];
    address = json["address"] == null ? null : Address.fromJson(json["address"]);
    nic = json["NIC"];
    iqamaNumber = json["iqamaNumber"] == null
        ? null
        : IqamaNumber.fromJson(json["iqamaNumber"]);
    passport = json["passport"] == null ? null : Passport.fromJson(json["passport"]);
    imigrationSatus = json["imigrationSatus"];
    dob = json["DOB"];
    age = json["age"];
    phoneNumber = json["phoneNumber"] == null
        ? null
        : (json["phoneNumber"] as List)
        .map((e) => PhoneNumber.fromJson(e))
        .toList();
    gender = json["gender"];
    role = json["role"];
    profession = json["profession"];
    nationality = json["nationality"];
    profilePic = json["profilePic"];
    familyInfo = json["familyInfo"] == null
        ? null
        : FamilyInfo.fromJson(json["familyInfo"]);
    educationInfo = json["educationInfo"] == null
        ? null
        : (json["educationInfo"] as List)
        .map((e) => EducationInfo.fromJson(e))
        .toList();
    experienceBackground = json["experienceBackground"] == null
        ? null
        : (json["experienceBackground"] as List)
        .map((e) => ExperienceBackground.fromJson(e))
        .toList();
    bankingInfo = json["bankingInfo"] == null
        ? null
        : (json["bankingInfo"] as List)
        .map((e) => BankingInfo.fromJson(e))
        .toList();
    employeeInfo = json["employeeInfo"] == null
        ? null
        : (json["employeeInfo"] as List)
        .map((e) => EmployeeInfo.fromJson(e))
        .toList();
    salaryInfo = json["salaryInfo"] == null
        ? null
        : SalaryInfo.fromJson(json["salaryInfo"]);
    socialLinks = json["socialLinks"] == null
        ? null
        : (json["socialLinks"] as List)
        .map((e) => SocialLinks.fromJson(e))
        .toList();
    loanInfo = json["loanInfo"] == null
        ? null
        : (json["loanInfo"] as List).map((e) => LoanInfo.fromJson(e)).toList();
    assetsInfo = json["assetsInfo"] == null
        ? null
        :  List<dynamic>.from(json["assetsInfo"]
        .map((e) => e is Map<String, dynamic> ? AssetsInfo.fromJson(e) : e));
    approvals = json["approvals"] == null
        ? null
        : (json["approvals"] as List).map((e) => Approvals.fromJson(e)).toList();
    contractInfo = json["contractInfo"] == null
        ? null
        : (json["contractInfo"] as List)
        .map((e) => ContractInfo.fromJson(e))
        .toList();
    documentsInfo = json["documentsInfo"] == null
        ? null
        : List<dynamic>.from(json["documentsInfo"]
        .map((e) => e is Map<String, dynamic> ? DocumentsInfo.fromJson(e) : e));
    createdBy = json["createdBy"];
    branchId = json["branchId"];
    departmentId = json["departmentId"];
    organizationId = json["organizationId"];
    v = json["__v"];
    leaveBalance = json["leaveBalance"] == null
        ? null
        : LeaveBalance.fromJson(json["leaveBalance"]);
    shiftInfo = json["shiftInfo"] == null ? null : ShiftInfo.fromJson(json["shiftInfo"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["userName"] = userName;
    _data["password"] = password;
    if (email != null) {
      _data["email"] = email?.map((e) => e.toJson()).toList();
    }
    _data["firstName"] = firstName;
    _data["middleName"] = middleName;
    _data["lastName"] = lastName;
    _data["martialStatus"] = martialStatus;
    _data["religion"] = religion;
    if (address != null) {
      _data["address"] = address?.toJson();
    }
    _data["NIC"] = nic;
    if (iqamaNumber != null) {
      _data["iqamaNumber"] = iqamaNumber?.toJson();
    }
    if (passport != null) {
      _data["passport"] = passport?.toJson();
    }
    _data["imigrationSatus"] = imigrationSatus;
    _data["DOB"] = dob;
    _data["age"] = age;
    if (phoneNumber != null) {
      _data["phoneNumber"] = phoneNumber?.map((e) => e.toJson()).toList();
    }
    _data["gender"] = gender;
    _data["role"] = role;
    _data["profession"] = profession;
    _data["nationality"] = nationality;
    _data["profilePic"] = profilePic;
    if (familyInfo != null) {
      _data["familyInfo"] = familyInfo?.toJson();
    }
    if (educationInfo != null) {
      _data["educationInfo"] =
          educationInfo?.map((e) => e.toJson()).toList();
    }
    if (experienceBackground != null) {
      _data["experienceBackground"] =
          experienceBackground?.map((e) => e.toJson()).toList();
    }
    if (bankingInfo != null) {
      _data["bankingInfo"] = bankingInfo?.map((e) => e.toJson()).toList();
    }
    if (employeeInfo != null) {
      _data["employeeInfo"] = employeeInfo?.map((e) => e.toJson()).toList();
    }
    if (salaryInfo != null) {
      _data["salaryInfo"] = salaryInfo?.toJson();
    }
    if (socialLinks != null) {
      _data["socialLinks"] = socialLinks?.map((e) => e.toJson()).toList();
    }
    if (loanInfo != null) {
      _data["loanInfo"] = loanInfo?.map((e) => e.toJson()).toList();
    }

    if (assetsInfo != null) {
      _data["assetsInfo"] = assetsInfo?.map((e) {
        if (e is AssetsInfo) {
          return e.toJson();
        }
        return e; // Handle dynamic type
      }).toList();
    }

    if (approvals != null) {
      _data["approvals"] = approvals?.map((e) => e.toJson()).toList();
    }
    if (contractInfo != null) {
      _data["contractInfo"] = contractInfo?.map((e) => e.toJson()).toList();
    }
    if (documentsInfo != null) {
      _data["documentsInfo"] = documentsInfo?.map((e) {
        if (e is DocumentsInfo) {
          return e.toJson();
        }
        return e; // Handle dynamic type
      }).toList();
    }
    _data["createdBy"] = createdBy;
    _data["branchId"] = branchId;
    _data["departmentId"] = departmentId;
    _data["organizationId"] = organizationId;
    _data["__v"] = v;
    if (leaveBalance != null) {
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
  PaidLeave? paidLeave;
  ShortLeavesMonthlyBal? shortLeavesMonthlyBal;
  SickLeave? sickLeave;
  List<SpecialLeave>? specialLeave;
  UnPaidLeave? unPaidLeave;

  LeaveBalance({this.annualLeave, this.casualLeave, this.paidLeave, this.shortLeavesMonthlyBal, this.sickLeave, this.specialLeave, this.unPaidLeave});

  LeaveBalance.fromJson(Map<String, dynamic> json) {
    annualLeave = json["annualLeave"] == null ? null : AnnualLeave.fromJson(json["annualLeave"]);
    casualLeave = json["casualLeave"] == null ? null : CasualLeave.fromJson(json["casualLeave"]);
    paidLeave = json["paidLeave"] == null ? null : PaidLeave.fromJson(json["paidLeave"]);
    shortLeavesMonthlyBal = json["shortLeavesMonthlyBal"] == null ? null : ShortLeavesMonthlyBal.fromJson(json["shortLeavesMonthlyBal"]);
    sickLeave = json["sickLeave"] == null ? null : SickLeave.fromJson(json["sickLeave"]);
    specialLeave = json["specialLeave"] == null ? null : (json["specialLeave"] as List).map((e) => SpecialLeave.fromJson(e)).toList();
    unPaidLeave = json["unPaidLeave"] == null ? null : UnPaidLeave.fromJson(json["unPaidLeave"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if(annualLeave != null) {
      _data["annualLeave"] = annualLeave?.toJson();
    }
    if(casualLeave != null) {
      _data["casualLeave"] = casualLeave?.toJson();
    }
    if(paidLeave != null) {
      _data["paidLeave"] = paidLeave?.toJson();
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
    if(unPaidLeave != null) {
      _data["unPaidLeave"] = unPaidLeave?.toJson();
    }
    return _data;
  }
}

class UnPaidLeave {
  dynamic entitlement;
  dynamic remaining;
  dynamic used;

  UnPaidLeave({this.entitlement, this.remaining, this.used});

  UnPaidLeave.fromJson(Map<String, dynamic> json) {
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

class PaidLeave {
  dynamic entitlement;
  dynamic remaining;
  dynamic used;

  PaidLeave({this.entitlement, this.remaining, this.used});

  PaidLeave.fromJson(Map<String, dynamic> json) {
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
  dynamic session;
  dynamic dailyEarned;

  AnnualLeave({this.currentMonth, this.entitlement, this.remaining, this.used, this.session, this.dailyEarned});

  AnnualLeave.fromJson(Map<String, dynamic> json) {
    currentMonth = json["currentMonth"];
    entitlement = json["entitlement"];
    remaining = json["remaining"];
    used = json["used"];
    session = json["session"] == null ? null : Session.fromJson(json["session"]);
    dailyEarned = json["dailyEarned"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["currentMonth"] = currentMonth;
    _data["entitlement"] = entitlement;
    _data["remaining"] = remaining;
    _data["used"] = used;
    if(session != null) {
      _data["session"] = session?.toJson();
    }
    _data["dailyEarned"] = dailyEarned;
    return _data;
  }
}

class Session {
  dynamic start;
  dynamic end;

  Session({this.start, this.end});

  Session.fromJson(Map<String, dynamic> json) {
    start = json["start"];
    end = json["end"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["start"] = start;
    _data["end"] = end;
    return _data;
  }
}

class DocumentsInfo {
  dynamic type;
  dynamic remarks;
  dynamic url;
  dynamic format;
  dynamic empId;
  dynamic expiration;
  dynamic size;

  DocumentsInfo(
      {this.type, this.remarks, this.url, this.format, this.empId, this.expiration, this.size});

  DocumentsInfo.fromJson(Map<String, dynamic> json) {
    type = json["type"];
    remarks = json["remarks"];
    url = json["URL"];
    format = json["format"];
    empId = json["empId"];
    expiration = json["expiration"];
    size = json["size"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["type"] = type;
    _data["remarks"] = remarks;
    _data["URL"] = url;
    _data["format"] = format;
    _data["empId"] = empId;
    _data["expiration"] = expiration;
    _data["size"] = size;
    return _data;
  }
}


class ContractInfo {
  dynamic contractId;
  dynamic contractStatus;
  dynamic contractType;
  dynamic contractStartDate;
  dynamic contractExpiry;
  dynamic probabtionStartDate;
  dynamic probationPeriod;
  dynamic probationstatus;

  ContractInfo({this.contractId, this.contractStatus, this.contractType, this.contractStartDate, this.contractExpiry, this.probabtionStartDate, this.probationPeriod, this.probationstatus});

  ContractInfo.fromJson(Map<String, dynamic> json) {
    contractId = json["contractId"];
    contractStatus = json["contractStatus"];
    contractType = json["contractType"];
    contractStartDate = json["contractStartDate"];
    contractExpiry = json["contractExpiry"];
    probabtionStartDate = json["probabtionStartDate"];
    probationPeriod = json["probationPeriod"];
    probationstatus = json["probationstatus"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["contractId"] = contractId;
    _data["contractStatus"] = contractStatus;
    _data["contractType"] = contractType;
    _data["contractStartDate"] = contractStartDate;
    _data["contractExpiry"] = contractExpiry;
    _data["probabtionStartDate"] = probabtionStartDate;
    _data["probationPeriod"] = probationPeriod;
    _data["probationstatus"] = probationstatus;
    return _data;
  }
}

class Approvals {
  dynamic approvalId;
  dynamic approvalType;
  dynamic approvalTitle;
  dynamic approvalStatus;

  Approvals({this.approvalId, this.approvalType, this.approvalTitle, this.approvalStatus});

  Approvals.fromJson(Map<String, dynamic> json) {
    approvalId = json["approvalId"];
    approvalType = json["approvalType"];
    approvalTitle = json["approvalTitle"];
    approvalStatus = json["approvalStatus"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["approvalId"] = approvalId;
    _data["approvalType"] = approvalType;
    _data["approvalTitle"] = approvalTitle;
    _data["approvalStatus"] = approvalStatus;
    return _data;
  }
}

class AssetsInfo {
  dynamic assetName;
  dynamic assetType;
  dynamic assetId;
  dynamic issueDateFrom;
  dynamic issueDateTo;

  AssetsInfo({this.assetName, this.assetId ,  this.assetType, this.issueDateFrom, this.issueDateTo});

  AssetsInfo.fromJson(Map<String, dynamic> json) {
    assetName = json["assetName"];
    assetId = json["assetId"];
    assetType = json["assetType"];
    issueDateFrom = json["issueDateFrom"];
    issueDateTo = json["issueDateTo"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["assetName"] = assetName;
    _data["assetId"] = assetId;
    _data["assetType"] = assetType;
    _data["issueDateFrom"] = issueDateFrom;
    _data["issueDateTo"] = issueDateTo;
    return _data;
  }
}

class LoanInfo {
  dynamic totalLoanAmount;
  dynamic loanIssueDate;
  dynamic loanDuration;
  dynamic installmentAmount;
  dynamic paidAmount;
  dynamic totalInstallments;
  dynamic paidInstallments;

  LoanInfo({this.totalLoanAmount, this.loanIssueDate, this.loanDuration, this.installmentAmount, this.paidAmount, this.totalInstallments, this.paidInstallments});

  LoanInfo.fromJson(Map<String, dynamic> json) {
    totalLoanAmount = json["totalLoanAmount"];
    loanIssueDate = json["loanIssueDate"];
    loanDuration = json["loanDuration"];
    installmentAmount = json["installmentAmount"];
    paidAmount = json["paidAmount"];
    totalInstallments = json["totalInstallments"];
    paidInstallments = json["paidInstallments"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["totalLoanAmount"] = totalLoanAmount;
    _data["loanIssueDate"] = loanIssueDate;
    _data["loanDuration"] = loanDuration;
    _data["installmentAmount"] = installmentAmount;
    _data["paidAmount"] = paidAmount;
    _data["totalInstallments"] = totalInstallments;
    _data["paidInstallments"] = paidInstallments;
    return _data;
  }
}

class SocialLinks {
  dynamic platformName;
  dynamic platformIcon;
  dynamic platformUrl;
  dynamic profileUrl;

  SocialLinks({this.platformName, this.platformIcon, this.platformUrl, this.profileUrl});

  SocialLinks.fromJson(Map<String, dynamic> json) {
    platformName = json["platformName"];
    platformIcon = json["platformIcon"];
    platformUrl = json["platformURL"];
    profileUrl = json["profileURL"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["platformName"] = platformName;
    _data["platformIcon"] = platformIcon;
    _data["platformURL"] = platformUrl;
    _data["profileURL"] = profileUrl;
    return _data;
  }
}

class SalaryInfo {
  dynamic baseSalary;
  dynamic currency;
  dynamic timeCyclePeriod;
  List<AllowanceBenefits>? allowanceBenefits;
  List<Deductions>? deductions;
  TaxInfo? taxInfo;
  dynamic allowanceContribution;
  dynamic netSalary;

  SalaryInfo({this.baseSalary, this.currency, this.timeCyclePeriod, this.allowanceBenefits, this.deductions, this.taxInfo, this.allowanceContribution, this.netSalary});

  SalaryInfo.fromJson(Map<String, dynamic> json) {
    baseSalary = json["baseSalary"];
    currency = json["currency"];
    timeCyclePeriod = json["timeCycle_Period"];
    allowanceBenefits = json["allowance_Benefits"] == null ? null : (json["allowance_Benefits"] as List).map((e) => AllowanceBenefits.fromJson(e)).toList();
    deductions = json["deductions"] == null ? null : (json["deductions"] as List).map((e) => Deductions.fromJson(e)).toList();
    taxInfo = json["taxInfo"] == null ? null : TaxInfo.fromJson(json["taxInfo"]);
    allowanceContribution = json["allowanceContribution"];
    netSalary = json["netSalary"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["baseSalary"] = baseSalary;
    _data["currency"] = currency;
    _data["timeCycle_Period"] = timeCyclePeriod;
    if(allowanceBenefits != null) {
      _data["allowance_benefits"] = allowanceBenefits?.map((e) => e.toJson()).toList();
    }
    if(deductions != null) {
      _data["deductions"] = deductions?.map((e) => e.toJson()).toList();
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

class Deductions {
  dynamic deductionTitle;
  dynamic deductionType;
  dynamic amount;
  dynamic basedOn;

  Deductions({this.deductionTitle, this.deductionType, this.amount, this.basedOn});

  Deductions.fromJson(Map<String, dynamic> json) {
    deductionTitle = json["deductionTitle"];
    deductionType = json["deductionType"];
    amount = json["amount"];
    basedOn = json["basedOn"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["deductionTitle"] = deductionTitle;
    _data["deductionType"] = deductionType;
    _data["amount"] = amount;
    _data["basedOn"] = basedOn;
    return _data;
  }
}

class AllowanceBenefits {
  dynamic allowanceTitle;
  dynamic allowanceType;
  dynamic amount;
  dynamic basedOn;

  AllowanceBenefits({this.allowanceTitle, this.allowanceType, this.amount, this.basedOn});

  AllowanceBenefits.fromJson(Map<String, dynamic> json) {
    allowanceTitle = json["allowanceTitle"];
    allowanceType = json["allowanceType"];
    amount = json["amount"];
    basedOn = json["basedOn"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["allowanceTitle"] = allowanceTitle;
    _data["allowanceType"] = allowanceType;
    _data["amount"] = amount;
    _data["basedOn"] = basedOn;
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

  EmployeeInfo({this.depId, this.depName, this.jobTitle, this.jobDescription, this.reportingManager, this.jobRank, this.designation, this.grade, this.workDomain, this.location, this.employeeStatus, this.employeeType, this.employeeShift, this.joiningDate, this.leavingDate, this.hiringDate, this.noticePeriod, this.empId , this.empSignature});

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

class ExperienceBackground {
  dynamic jobTitle;
  dynamic company;
  dynamic referenceName;
  dynamic referenceContact;
  dynamic duration;
  dynamic from;
  dynamic to;
  dynamic description;

  ExperienceBackground({this.jobTitle, this.company, this.referenceName, this.referenceContact, this.duration, this.from, this.to, this.description});

  ExperienceBackground.fromJson(Map<String, dynamic> json) {
    jobTitle = json["jobTitle"];
    company = json["company"];
    referenceName = json["referenceName"];
    referenceContact = json["referenceContact"];
    duration = json["duration"];
    from = json["from"];
    to = json["to"];
    description = json["description"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["jobTitle"] = jobTitle;
    _data["company"] = company;
    _data["referenceName"] = referenceName;
    _data["referenceContact"] = referenceContact;
    _data["duration"] = duration;
    _data["from"] = from;
    _data["to"] = to;
    _data["description"] = description;
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
  dynamic personalEmail;
  dynamic workEmail;

  Email({this.personalEmail, this.workEmail});

  Email.fromJson(Map<String, dynamic> json) {
    personalEmail = json["personalEmail"];
    workEmail = json["workEmail"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["personalEmail"] = personalEmail;
    _data["workEmail"] = workEmail;
    return _data;
  }
}