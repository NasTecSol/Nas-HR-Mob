class RequestDataModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  Data? data;

  RequestDataModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  RequestDataModel.fromJson(Map<String, dynamic> json) {
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
  List<Data1>? data;
  int? total;
  int? page;
  int? limit;
  int? totalPages;

  Data({this.data, this.total, this.page, this.limit, this.totalPages});

  Data.fromJson(Map<String, dynamic> json) {
    data = json["data"] == null ? null : (json["data"] as List).map((e) => Data1.fromJson(e)).toList();
    total = json["total"];
    page = json["page"];
    limit = json["limit"];
    totalPages = json["totalPages"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if(data != null) {
      _data["data"] = data?.map((e) => e.toJson()).toList();
    }
    _data["total"] = total;
    _data["page"] = page;
    _data["limit"] = limit;
    _data["totalPages"] = totalPages;
    return _data;
  }
}
class Data1 {
  String? id;
  String? employeeId;
  String? employeeName;
  String? empId;
  String? companyId;
  String? branchId;
  String? policyId;
  String? requestType;
  String? subType;
  List<RequestData>? requestData;
  List<Approvers>? approvers;
  String? reason;
  List<Attachments>? attachments;
  String? createdAt;
  String? updatedAt;
  int? v;
  String? status;

  Data1({this.id, this.employeeId, this.employeeName, this.empId, this.companyId, this.branchId, this.policyId, this.requestType, this.subType, this.requestData, this.approvers, this.reason, this.attachments, this.createdAt, this.updatedAt, this.v, this.status});

  Data1.fromJson(Map<String, dynamic> json) {
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
    attachments = json["attachments"] == null ? null : (json["attachments"] as List).map((e) => Attachments.fromJson(e)).toList();
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
      _data["attachments"] = attachments?.map((e) => e.toJson()).toList();
    }
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    _data["status"] = status;
    return _data;
  }
}

class Attachments {
  String? fileName;
  String? fileType;
  String? fileContent;

  Attachments({this.fileName, this.fileType, this.fileContent});

  Attachments.fromJson(Map<String, dynamic> json) {
    fileName = json["fileName"];
    fileType = json["fileType"];
    fileContent = json["fileContent"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["fileName"] = fileName;
    _data["fileType"] = fileType;
    _data["fileContent"] = fileContent;
    return _data;
  }
}

class Approvers {
  String? approverId;
  String? approverName;
  bool? isRequired;
  String? status;
  String? timeStamps;
  String? comments;

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
  // Common keys (Employees list)
  List<Employees>? employees;

  // Leave
  dynamic startDate;
  dynamic endDate;
  dynamic duration;
  dynamic leaveType;

  // Loan
  dynamic loanAmount;
  dynamic loanCycle;
  dynamic loanInstallment;
  dynamic loanDuration;
  dynamic loanType;

  // Penalties/Fines
  dynamic finePenality;
  dynamic amount;
  dynamic details;
  dynamic remark;

  // Expense
  dynamic purpose;
  dynamic description;
  dynamic expenseDate;
  dynamic category;
  dynamic paymentMethod;
  bool? isAdvanceUsed;
  dynamic transactionType;

  // Document Request
  dynamic docType;
  dynamic name;
  dynamic notes;
  dynamic documentType;
  dynamic documentName;

  // Overtime Request
  dynamic overTimeHours;
  Map<String, dynamic>? paidAs;
  List<Map<String, dynamic>>? to;

  // Attendance Request
  dynamic punchingType;
  dynamic attendanceTime;
  dynamic attendanceDate;

  // 🔥 NEW FIELD (Single date for: expense, overtime, documents, penalties)
  dynamic date;

  // Extra storage for any unrecognized keys
  Map<String, dynamic>? extra;

  RequestData({
    this.employees,
    this.startDate,
    this.endDate,
    this.duration,
    this.leaveType,
    this.loanAmount,
    this.loanCycle,
    this.loanInstallment,
    this.loanDuration,
    this.loanType,
    this.finePenality,
    this.amount,
    this.details,
    this.remark,
    this.purpose,
    this.description,
    this.expenseDate,
    this.category,
    this.paymentMethod,
    this.isAdvanceUsed,
    this.transactionType,
    this.docType,
    this.name,
    this.notes,
    this.documentType,
    this.documentName,
    this.overTimeHours,
    this.paidAs,
    this.to,
    this.punchingType,
    this.attendanceTime,
    this.attendanceDate,
    this.date, // NEW FIELD
    this.extra,
  });

  /// ---------- FROM JSON ----------
  RequestData.fromJson(Map<String, dynamic> json) {
    employees = json["employees"] == null
        ? null
        : (json["employees"] as List)
        .map((e) => Employees.fromJson(e))
        .toList();

    // Direct keys
    startDate = json["startDate"];
    endDate = json["endDate"];
    duration = json["duration"];
    leaveType = json["leaveType"];

    loanAmount = json["loanAmount"];
    loanCycle = json["loanCycle"];
    loanInstallment = json["loanInstallment"];
    loanDuration = json["loanDuration"];
    loanType = json["loanType"];

    finePenality = json["fine_penality"];
    amount = json["amount"];
    details = json["details"];
    remark = json["remark"];

    purpose = json["purpose"];
    description = json["description"];
    expenseDate = json["expenseDate"];
    category = json["category"];
    paymentMethod = json["paymentMethod"];
    isAdvanceUsed = json["isAdvanceUsed"];
    transactionType = json["transactionType"];

    docType = json["docType"];
    name = json["name"];
    notes = json["remarks"];
    documentType = json["documentType"];
    documentName = json["documentName"];

    overTimeHours = json["overTimeHours"];
    paidAs = json["paidAs"];
    to = json["to"]?.cast<Map<String, dynamic>>();

    punchingType = json["punchingType"];
    attendanceTime = json["attendanceTime"];
    attendanceDate = json["attendanceDate"];

    date = json["date"]; // NEW FIELD

    // Save extra unknown keys
    extra = {};
    json.forEach((key, value) {
      if (!toJson().containsKey(key)) {
        extra![key] = value;
      }
    });
  }

  /// ---------- TO JSON ----------
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (employees != null) {
      data["employees"] = employees!.map((e) => e.toJson()).toList();
    }

    data["startDate"] = startDate;
    data["endDate"] = endDate;
    data["duration"] = duration;
    data["leaveType"] = leaveType;

    data["loanAmount"] = loanAmount;
    data["loanCycle"] = loanCycle;
    data["loanInstallment"] = loanInstallment;
    data["loanDuration"] = loanDuration;
    data["loanType"] = loanType;

    data["fine_penality"] = finePenality;
    data["amount"] = amount;
    data["details"] = details;
    data["remark"] = remark;

    data["purpose"] = purpose;
    data["description"] = description;
    data["expenseDate"] = expenseDate;
    data["category"] = category;
    data["paymentMethod"] = paymentMethod;
    data["isAdvanceUsed"] = isAdvanceUsed;
    data["transactionType"] = transactionType;

    data["docType"] = docType;
    data["name"] = name;
    data["remarks"] = notes;
    data["documentType"] = documentType;
    data["documentName"] = documentName;

    data["overTimeHours"] = overTimeHours;
    data["paidAs"] = paidAs;
    data["to"] = to;

    data["punchingType"] = punchingType;
    data["attendanceTime"] = attendanceTime;
    data["attendanceDate"] = attendanceDate;

    data["date"] = date; // NEW FIELD

    // Add unknown extra keys
    if (extra != null) {
      data.addAll(extra!);
    }

    return data;
  }
}


class Employees {
  String? empId;
  String? name;
  int? severity;

  Employees({this.empId, this.name, this.severity});

  Employees.fromJson(Map<String, dynamic> json) {
    empId = json["empId"];
    name = json["name"];
    severity = json["severity"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["empId"] = empId;
    _data["name"] = name;
    _data["severity"] = severity;
    return _data;
  }
}
