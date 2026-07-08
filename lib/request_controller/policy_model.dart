class PolicyModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  Data? data;

  PolicyModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  PolicyModel.fromJson(Map<String, dynamic> json) {
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
  dynamic organizationId;
  dynamic policyName;
  dynamic policyType;
  AnnualLeave? annualLeave;
  CasualLeave? casualLeave;
  List<SpecialLeave>? specialLeave;
  MaternityLeave? maternityLeave;
  SickLeave? sickLeave;
  HolidayPolicy? holidayPolicy;
  AttendancePolicy? attendancePolicy;
  dynamic createdBy;
  dynamic closingYearDate;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic v;
  CoreHours? coreHours;
  WorkingDays? workingDays;
  List<PenaltiesFines>? penaltiesFines;
  Loan? loan;

  Data({this.id, this.organizationId, this.policyName, this.policyType, this.annualLeave, this.casualLeave, this.specialLeave, this.maternityLeave, this.sickLeave, this.holidayPolicy, this.attendancePolicy, this.createdBy, this.closingYearDate, this.createdAt, this.updatedAt, this.v, this.coreHours, this.workingDays, this.penaltiesFines, this.loan});

  Data.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    organizationId = json["organizationId"];
    policyName = json["policyName"];
    policyType = json["policyType"];
    annualLeave = json["annualLeave"] == null ? null : AnnualLeave.fromJson(json["annualLeave"]);
    casualLeave = json["casualLeave"] == null ? null : CasualLeave.fromJson(json["casualLeave"]);
    specialLeave = json["specialLeave"] == null ? null : (json["specialLeave"] as List).map((e) => SpecialLeave.fromJson(e)).toList();
    maternityLeave = json["maternityLeave"] == null ? null : MaternityLeave.fromJson(json["maternityLeave"]);
    sickLeave = json["sickLeave"] == null ? null : SickLeave.fromJson(json["sickLeave"]);
    holidayPolicy = json["holidayPolicy"] == null ? null : HolidayPolicy.fromJson(json["holidayPolicy"]);
    attendancePolicy = json["attendancePolicy"] == null ? null : AttendancePolicy.fromJson(json["attendancePolicy"]);
    createdBy = json["createdBy"];
    closingYearDate = json["closingYearDate"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
    coreHours = json["coreHours"] == null ? null : CoreHours.fromJson(json["coreHours"]);
    workingDays = json["workingDays"] == null ? null : WorkingDays.fromJson(json["workingDays"]);
    penaltiesFines = json["penalties_fines"] == null ? null : (json["penalties_fines"] as List).map((e) => PenaltiesFines.fromJson(e)).toList();
    loan = json["loan"] == null ? null : Loan.fromJson(json["loan"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["organizationId"] = organizationId;
    _data["policyName"] = policyName;
    _data["policyType"] = policyType;
    if(annualLeave != null) {
      _data["annualLeave"] = annualLeave?.toJson();
    }
    if(casualLeave != null) {
      _data["casualLeave"] = casualLeave?.toJson();
    }
    if(specialLeave != null) {
      _data["specialLeave"] = specialLeave?.map((e) => e.toJson()).toList();
    }
    if(maternityLeave != null) {
      _data["maternityLeave"] = maternityLeave?.toJson();
    }
    if(sickLeave != null) {
      _data["sickLeave"] = sickLeave?.toJson();
    }
    if(holidayPolicy != null) {
      _data["holidayPolicy"] = holidayPolicy?.toJson();
    }
    if(attendancePolicy != null) {
      _data["attendancePolicy"] = attendancePolicy?.toJson();
    }
    _data["createdBy"] = createdBy;
    _data["closingYearDate"] = closingYearDate;
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    if(coreHours != null) {
      _data["coreHours"] = coreHours?.toJson();
    }
    if(workingDays != null) {
      _data["workingDays"] = workingDays?.toJson();
    }
    if(penaltiesFines != null) {
      _data["penalties_fines"] = penaltiesFines?.map((e) => e.toJson()).toList();
    }
    if(loan != null) {
      _data["loan"] = loan?.toJson();
    }
    return _data;
  }
}

class Loan {
  dynamic maximumAmount;
  dynamic maxPercentageSalary;
  dynamic parallelLoans;
  dynamic experienceLimit;

  Loan({this.maximumAmount, this.maxPercentageSalary, this.parallelLoans, this.experienceLimit});

  Loan.fromJson(Map<String, dynamic> json) {
    maximumAmount = json["maximumAmount"];
    maxPercentageSalary = json["maxPercentageSalary"];
    parallelLoans = json["parallelLoans"];
    experienceLimit = json["experienceLimit"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["maximumAmount"] = maximumAmount;
    _data["maxPercentageSalary"] = maxPercentageSalary;
    _data["parallelLoans"] = parallelLoans;
    _data["experienceLimit"] = experienceLimit;
    return _data;
  }
}

class PenaltiesFines {
  dynamic penalityName;
  dynamic penalityCode;
  dynamic description;
  dynamic fineAmount;
  dynamic penalityType;
  dynamic fineType;

  PenaltiesFines({this.penalityName, this.penalityCode, this.description, this.fineAmount , this.fineType , this.penalityType});

  PenaltiesFines.fromJson(Map<String, dynamic> json) {
    penalityName = json["penalityName"];
    penalityCode = json["penalityCode"];
    description = json["description"];
    fineAmount = json["fineAmount"];
    penalityType = json["penalityType"];
    fineType = json["fineType"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["penalityName"] = penalityName;
    _data["penalityCode"] = penalityCode;
    _data["description"] = description;
    _data["fineAmount"] = fineAmount;
    _data["penalityType"] = penalityType;
    _data["fineType"] = fineType;
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

class CoreHours {
  dynamic startTime;
  dynamic endTime;

  CoreHours({this.startTime, this.endTime});

  CoreHours.fromJson(Map<String, dynamic> json) {
    startTime = json["startTime"];
    endTime = json["endTime"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["startTime"] = startTime;
    _data["endTime"] = endTime;
    return _data;
  }
}

class AttendancePolicy {
  List<ShiftTimings>? shiftTimings;
  FlexibleShifts? flexibleShifts;
  OvertimePolicy? overtimePolicy;
  BreakTime? breakTime;
  LateComingsPolicy? lateComingsPolicy;
  FlexibleWorkHours? flexibleWorkHours;
  List<ShortLeaves>? shortLeaves;
  AbsentPolicy? absentPolicy;
  ShortLeavesMonthlyBalance? shortLeavesMonthlyBalance;
  EmpBalancePolicy? empBalancePolicy;

  AttendancePolicy({this.shiftTimings, this.flexibleShifts, this.overtimePolicy, this.breakTime, this.lateComingsPolicy, this.flexibleWorkHours, this.shortLeaves, this.absentPolicy, this.shortLeavesMonthlyBalance, this.empBalancePolicy});

  AttendancePolicy.fromJson(Map<String, dynamic> json) {
    shiftTimings = json["shiftTimings"] == null ? null : (json["shiftTimings"] as List).map((e) => ShiftTimings.fromJson(e)).toList();
    flexibleShifts = json["flexibleShifts"] == null ? null : FlexibleShifts.fromJson(json["flexibleShifts"]);
    overtimePolicy = json["overtimePolicy"] == null ? null : OvertimePolicy.fromJson(json["overtimePolicy"]);
    breakTime = json["breakTime"] == null ? null : BreakTime.fromJson(json["breakTime"]);
    lateComingsPolicy = json["lateComingsPolicy"] == null ? null : LateComingsPolicy.fromJson(json["lateComingsPolicy"]);
    flexibleWorkHours = json["flexibleWorkHours"] == null ? null : FlexibleWorkHours.fromJson(json["flexibleWorkHours"]);
    shortLeaves = json["shortLeaves"] == null ? null : (json["shortLeaves"] as List).map((e) => ShortLeaves.fromJson(e)).toList();
    absentPolicy = json["absentPolicy"] == null ? null : AbsentPolicy.fromJson(json["absentPolicy"]);
    shortLeavesMonthlyBalance = json["shortLeavesMonthlyBalance"] == null ? null : ShortLeavesMonthlyBalance.fromJson(json["shortLeavesMonthlyBalance"]);
    empBalancePolicy = json["empBalancePolicy"] == null ? null : EmpBalancePolicy.fromJson(json["empBalancePolicy"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if(shiftTimings != null) {
      _data["shiftTimings"] = shiftTimings?.map((e) => e.toJson()).toList();
    }
    if(flexibleShifts != null) {
      _data["flexibleShifts"] = flexibleShifts?.toJson();
    }
    if(overtimePolicy != null) {
      _data["overtimePolicy"] = overtimePolicy?.toJson();
    }
    if(breakTime != null) {
      _data["breakTime"] = breakTime?.toJson();
    }
    if(lateComingsPolicy != null) {
      _data["lateComingsPolicy"] = lateComingsPolicy?.toJson();
    }
    if(flexibleWorkHours != null) {
      _data["flexibleWorkHours"] = flexibleWorkHours?.toJson();
    }
    if(shortLeaves != null) {
      _data["shortLeaves"] = shortLeaves?.map((e) => e.toJson()).toList();
    }
    if(absentPolicy != null) {
      _data["absentPolicy"] = absentPolicy?.toJson();
    }
    if(shortLeavesMonthlyBalance != null) {
      _data["shortLeavesMonthlyBalance"] = shortLeavesMonthlyBalance?.toJson();
    }
    if(empBalancePolicy != null) {
      _data["empBalancePolicy"] = empBalancePolicy?.toJson();
    }
    return _data;
  }
}

class EmpBalancePolicy {
  dynamic deductionType;
  dynamic deductionPercentage;
  dynamic deductionAmount;

  EmpBalancePolicy({this.deductionType, this.deductionPercentage, this.deductionAmount});

  EmpBalancePolicy.fromJson(Map<String, dynamic> json) {
    deductionType = json["deductionType"];
    deductionPercentage = json["deductionPercentage"];
    deductionAmount = json["deductionAmount"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["deductionType"] = deductionType;
    _data["deductionPercentage"] = deductionPercentage;
    _data["deductionAmount"] = deductionAmount;
    return _data;
  }
}

class ShortLeavesMonthlyBalance {
  int? shortLeaveBalance;

  ShortLeavesMonthlyBalance({this.shortLeaveBalance});

  ShortLeavesMonthlyBalance.fromJson(Map<String, dynamic> json) {
    shortLeaveBalance = json["shortLeaveBalance"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["shortLeaveBalance"] = shortLeaveBalance;
    return _data;
  }
}

class AbsentPolicy {
  dynamic absentDeductionType;
  dynamic deductionPercentage;
  dynamic deductionAmount;

  AbsentPolicy({this.absentDeductionType, this.deductionPercentage, this.deductionAmount});

  AbsentPolicy.fromJson(Map<String, dynamic> json) {
    absentDeductionType = json["absentDeductionType"];
    deductionPercentage = json["deductionPercentage"];
    deductionAmount = json["deductionAmount"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["absentDeductionType"] = absentDeductionType;
    _data["deductionPercentage"] = deductionPercentage;
    _data["deductionAmount"] = deductionAmount;
    return _data;
  }
}

class ShortLeaves {
  dynamic duration;
  bool? isApprovalRequired;
  dynamic shortLeave;

  ShortLeaves({this.duration, this.isApprovalRequired, this.shortLeave});

  ShortLeaves.fromJson(Map<String, dynamic> json) {
    duration = json["duration"];
    isApprovalRequired = json["isApprovalRequired"];
    shortLeave = json["shortLeave"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["duration"] = duration;
    _data["isApprovalRequired"] = isApprovalRequired;
    _data["shortLeave"] = shortLeave;
    return _data;
  }
}

class FlexibleWorkHours {
  bool? enabled;
  dynamic minDailyHours;
  dynamic weeklyHours;
  bool? carryOverHours;
  dynamic carryOverLimit;

  FlexibleWorkHours({this.enabled, this.minDailyHours, this.weeklyHours, this.carryOverHours, this.carryOverLimit});

  FlexibleWorkHours.fromJson(Map<String, dynamic> json) {
    enabled = json["enabled"];
    minDailyHours = json["minDailyHours"];
    weeklyHours = json["weeklyHours"];
    carryOverHours = json["carryOverHours"];
    carryOverLimit = json["carryOverLimit"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["enabled"] = enabled;
    _data["minDailyHours"] = minDailyHours;
    _data["weeklyHours"] = weeklyHours;
    _data["carryOverHours"] = carryOverHours;
    _data["carryOverLimit"] = carryOverLimit;
    return _data;
  }
}

class LateComingsPolicy {
  dynamic gracePeriodMinutes;
  List<Penalties>? penalties;

  LateComingsPolicy({this.gracePeriodMinutes, this.penalties});

  LateComingsPolicy.fromJson(Map<String, dynamic> json) {
    gracePeriodMinutes = json["gracePeriodMinutes"];
    penalties = json["penalties"] == null ? null : (json["penalties"] as List).map((e) => Penalties.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["gracePeriodMinutes"] = gracePeriodMinutes;
    if(penalties != null) {
      _data["penalties"] = penalties?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Penalties {
  dynamic delayRange;
  List<Penalty>? penalty;
  dynamic uniqueId;

  Penalties({this.delayRange, this.penalty, this.uniqueId});

  Penalties.fromJson(Map<String, dynamic> json) {
    delayRange = json["delayRange"];
    penalty = json["penalty"] == null ? null : (json["penalty"] as List).map((e) => Penalty.fromJson(e)).toList();
    uniqueId = json["uniqueId"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["delayRange"] = delayRange;
    if(penalty != null) {
      _data["penalty"] = penalty?.map((e) => e.toJson()).toList();
    }
    _data["uniqueId"] = uniqueId;
    return _data;
  }
}

class Penalty {
  dynamic occurence;
  dynamic action;
  dynamic percentage;

  Penalty({this.occurence, this.action, this.percentage});

  Penalty.fromJson(Map<String, dynamic> json) {
    occurence = json["occurence"];
    action = json["action"];
    percentage = json["percentage"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["occurence"] = occurence;
    _data["action"] = action;
    _data["percentage"] = percentage;
    return _data;
  }
}

class BreakTime {
  dynamic totalBreakTime;
  bool? breakFlexibility;
  dynamic durationMinutes;
  bool? breaksAllowed;
  dynamic maxBreaks;
  dynamic minBreakDurationMinutes;

  BreakTime({this.totalBreakTime, this.breakFlexibility, this.durationMinutes, this.breaksAllowed, this.maxBreaks, this.minBreakDurationMinutes});

  BreakTime.fromJson(Map<String, dynamic> json) {
    totalBreakTime = json["totalBreakTime"];
    breakFlexibility = json["breakFlexibility"];
    durationMinutes = json["durationMinutes"];
    breaksAllowed = json["breaksAllowed"];
    maxBreaks = json["maxBreaks"];
    minBreakDurationMinutes = json["minBreakDurationMinutes"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["totalBreakTime"] = totalBreakTime;
    _data["breakFlexibility"] = breakFlexibility;
    _data["durationMinutes"] = durationMinutes;
    _data["breaksAllowed"] = breaksAllowed;
    _data["maxBreaks"] = maxBreaks;
    _data["minBreakDurationMinutes"] = minBreakDurationMinutes;
    return _data;
  }
}

class OvertimePolicy {
  bool? isAllowed;
  bool? isAuto;
  bool? preApproval;
  String? approvalType;
  dynamic paidAs;
  dynamic amount;

  OvertimePolicy({this.isAllowed, this.isAuto, this.preApproval, this.paidAs, this.amount , this.approvalType});

  OvertimePolicy.fromJson(Map<String, dynamic> json) {
    isAllowed = json["isAllowed"];
    isAuto = json["isAuto"];
    preApproval = json["preApproval"];
    approvalType = json["approvalType"];
    paidAs = json["paidAs"];
    amount = json["amount"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["isAllowed"] = isAllowed;
    _data["isAuto"] = isAuto;
    _data["preApproval"] = preApproval;
    _data["approvalType"] = approvalType;
    _data["paidAs"] = paidAs;
    _data["amount"] = amount;
    return _data;
  }
}

class FlexibleShifts {
  bool? flexibleShiftsAllowed;
  bool? isAuto;
  bool? preApproval;

  FlexibleShifts({this.flexibleShiftsAllowed, this.isAuto, this.preApproval});

  FlexibleShifts.fromJson(Map<String, dynamic> json) {
    flexibleShiftsAllowed = json["flexibleShiftsAllowed"];
    isAuto = json["isAuto"];
    preApproval = json["preApproval"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["flexibleShiftsAllowed"] = flexibleShiftsAllowed;
    _data["isAuto"] = isAuto;
    _data["preApproval"] = preApproval;
    return _data;
  }
}

class ShiftTimings {
  dynamic shiftName;
  dynamic timeFrom;
  dynamic timeTo;
  dynamic startingFrom;
  dynamic totalHours;
  dynamic allowedBreak;

  ShiftTimings({this.shiftName, this.timeFrom, this.timeTo, this.startingFrom, this.totalHours, this.allowedBreak});

  ShiftTimings.fromJson(Map<String, dynamic> json) {
    shiftName = json["shiftName"];
    timeFrom = json["timeFrom"];
    timeTo = json["timeTo"];
    startingFrom = json["startingFrom"];
    totalHours = json["totalHours"];
    allowedBreak = json["allowedBreak"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["shiftName"] = shiftName;
    _data["timeFrom"] = timeFrom;
    _data["timeTo"] = timeTo;
    _data["startingFrom"] = startingFrom;
    _data["totalHours"] = totalHours;
    _data["allowedBreak"] = allowedBreak;
    return _data;
  }
}

class HolidayPolicy {
  List<Holidays>? holidays;
  CompensatoryPolicy? compensatoryPolicy;

  HolidayPolicy({this.holidays, this.compensatoryPolicy});

  HolidayPolicy.fromJson(Map<String, dynamic> json) {
    holidays = json["holidays"] == null ? null : (json["holidays"] as List).map((e) => Holidays.fromJson(e)).toList();
    compensatoryPolicy = json["compensatoryPolicy"] == null ? null : CompensatoryPolicy.fromJson(json["compensatoryPolicy"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if(holidays != null) {
      _data["holidays"] = holidays?.map((e) => e.toJson()).toList();
    }
    if(compensatoryPolicy != null) {
      _data["compensatoryPolicy"] = compensatoryPolicy?.toJson();
    }
    return _data;
  }
}

class CompensatoryPolicy {
  bool? compensateForWeekend;
  bool? noDoubleCompensation;

  CompensatoryPolicy({this.compensateForWeekend, this.noDoubleCompensation});

  CompensatoryPolicy.fromJson(Map<String, dynamic> json) {
    compensateForWeekend = json["compensateForWeekend"];
    noDoubleCompensation = json["noDoubleCompensation"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["compensateForWeekend"] = compensateForWeekend;
    _data["noDoubleCompensation"] = noDoubleCompensation;
    return _data;
  }
}

class Holidays {
  dynamic holidayName;
  dynamic startDate;
  dynamic endDate;
  dynamic isNationalHoliday;
  dynamic isAdjustedForWeekend;
  List<CompensatoryDays>? compensatoryDays;

  Holidays({this.holidayName, this.startDate, this.endDate, this.isNationalHoliday, this.isAdjustedForWeekend, this.compensatoryDays});

  Holidays.fromJson(Map<String, dynamic> json) {
    holidayName = json["holidayName"];
    startDate = json["startDate"];
    endDate = json["endDate"];
    isNationalHoliday = json["isNationalHoliday"];
    isAdjustedForWeekend = json["isAdjustedForWeekend"];
    compensatoryDays = json["compensatoryDays"] == null ? null : (json["compensatoryDays"] as List).map((e) => CompensatoryDays.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["holidayName"] = holidayName;
    _data["startDate"] = startDate;
    _data["endDate"] = endDate;
    _data["isNationalHoliday"] = isNationalHoliday;
    _data["isAdjustedForWeekend"] = isAdjustedForWeekend;
    if(compensatoryDays != null) {
      _data["compensatoryDays"] = compensatoryDays?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class CompensatoryDays {
  dynamic date;
  dynamic compensationFor;

  CompensatoryDays({this.date, this.compensationFor});

  CompensatoryDays.fromJson(Map<String, dynamic> json) {
    date = json["date"];
    compensationFor = json["compensationFor"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["date"] = date;
    _data["compensationFor"] = compensationFor;
    return _data;
  }
}

class SickLeave {
  int? fullPayDays;
  int? partialPayDays;
  bool? allowsCombinationWithAnnual;
  int? unPaidDays;

  SickLeave({this.fullPayDays, this.partialPayDays, this.allowsCombinationWithAnnual, this.unPaidDays});

  SickLeave.fromJson(Map<String, dynamic> json) {
    fullPayDays = json["fullPayDays"];
    partialPayDays = json["partialPayDays"];
    allowsCombinationWithAnnual = json["allowsCombinationWithAnnual"];
    unPaidDays = json["unPaidDays"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["fullPayDays"] = fullPayDays;
    _data["partialPayDays"] = partialPayDays;
    _data["allowsCombinationWithAnnual"] = allowsCombinationWithAnnual;
    _data["unPaidDays"] = unPaidDays;
    return _data;
  }
}

class MaternityLeave {
  Male? male;
  Female? female;

  MaternityLeave({this.male, this.female});

  MaternityLeave.fromJson(Map<String, dynamic> json) {
    male = json["male"] == null ? null : Male.fromJson(json["male"]);
    female = json["female"] == null ? null : Female.fromJson(json["female"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if(male != null) {
      _data["male"] = male?.toJson();
    }
    if(female != null) {
      _data["female"] = female?.toJson();
    }
    return _data;
  }
}

class Female {
  dynamic leavesAllowedMuslims;
  dynamic unpaid;
  dynamic leavesAllowedOthers;

  Female({this.leavesAllowedMuslims, this.unpaid, this.leavesAllowedOthers});

  Female.fromJson(Map<String, dynamic> json) {
    leavesAllowedMuslims = json["leavesAllowedMuslims"];
    unpaid = json["unpaid"];
    leavesAllowedOthers = json["leavesAllowedOthers"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["leavesAllowedMuslims"] = leavesAllowedMuslims;
    _data["unpaid"] = unpaid;
    _data["leavesAllowedOthers"] = leavesAllowedOthers;
    return _data;
  }
}

class Male {
  dynamic leavesAllowedMuslims;
  dynamic unpaid;
  dynamic leavesAllowedOthers;

  Male({this.leavesAllowedMuslims, this.unpaid, this.leavesAllowedOthers});

  Male.fromJson(Map<String, dynamic> json) {
    leavesAllowedMuslims = json["leavesAllowedMuslims"];
    unpaid = json["unpaid"];
    leavesAllowedOthers = json["leavesAllowedOthers"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["leavesAllowedMuslims"] = leavesAllowedMuslims;
    _data["unpaid"] = unpaid;
    _data["leavesAllowedOthers"] = leavesAllowedOthers;
    return _data;
  }
}

class SpecialLeave {
  dynamic leaveType;
  dynamic duration;
  bool? requiresDocumentation;
  List<String>? applicableTo;

  SpecialLeave({this.leaveType, this.duration, this.requiresDocumentation, this.applicableTo});

  SpecialLeave.fromJson(Map<String, dynamic> json) {
    leaveType = json["leaveType"];
    duration = json["duration"];
    requiresDocumentation = json["requiresDocumentation"];
    applicableTo = json["applicableTo"] == null ? null : List<String>.from(json["applicableTo"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["leaveType"] = leaveType;
    _data["duration"] = duration;
    _data["requiresDocumentation"] = requiresDocumentation;
    if(applicableTo != null) {
      _data["applicableTo"] = applicableTo;
    }
    return _data;
  }
}

class CasualLeave {
  dynamic totalCasualLeaves;
  bool? isYearly;
  bool? carryForward;

  CasualLeave({this.totalCasualLeaves, this.isYearly, this.carryForward});

  CasualLeave.fromJson(Map<String, dynamic> json) {
    totalCasualLeaves = json["totalCasualLeaves"];
    isYearly = json["isYearly"];
    carryForward = json["carryForward"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["totalCasualLeaves"] = totalCasualLeaves;
    _data["isYearly"] = isYearly;
    _data["carryForward"] = carryForward;
    return _data;
  }
}

class AnnualLeave {
  dynamic entitlement;
  dynamic entitlementAfterYears;
  dynamic increasedEntitlement;
  bool? carryForward;
  bool? distributionOverMonthAllowed;
  dynamic perMonthDistribution;

  AnnualLeave({this.entitlement, this.entitlementAfterYears, this.increasedEntitlement, this.carryForward, this.distributionOverMonthAllowed, this.perMonthDistribution});

  AnnualLeave.fromJson(Map<String, dynamic> json) {
    entitlement = json["entitlement"];
    entitlementAfterYears = json["entitlementAfterYears"];
    increasedEntitlement = json["increasedEntitlement"];
    carryForward = json["carryForward"];
    distributionOverMonthAllowed = json["distributionOverMonthAllowed"];
    perMonthDistribution = json["perMonthDistribution"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["entitlement"] = entitlement;
    _data["entitlementAfterYears"] = entitlementAfterYears;
    _data["increasedEntitlement"] = increasedEntitlement;
    _data["carryForward"] = carryForward;
    _data["distributionOverMonthAllowed"] = distributionOverMonthAllowed;
    _data["perMonthDistribution"] = perMonthDistribution;
    return _data;
  }
}