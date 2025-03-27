class PenaltiesAndFineModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  Data? data;

  PenaltiesAndFineModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  PenaltiesAndFineModel.fromJson(Map<String, dynamic> json) {
    statusCode = json["statusCode"];
    statusMessage = json["statusMessage"];
    errorMessage = json["errorMessage"];
    data = json["data"] != null ? Data.fromJson(json["data"]) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      "statusCode": statusCode,
      "statusMessage": statusMessage,
      "errorMessage": errorMessage,
      "data": data?.toJson(),
    };
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
    if (json["data"] != null && json["data"] is List) {
      data = (json["data"] as List).map((e) => Data1.fromJson(e)).toList();
    } else {
      data = [];
    }
    total = json["total"];
    page = json["page"];
    limit = json["limit"];
    totalPages = json["totalPages"];
  }

  Map<String, dynamic> toJson() {
    return {
      "data": data?.map((e) => e.toJson()).toList(),
      "total": total,
      "page": page,
      "limit": limit,
      "totalPages": totalPages,
    };
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
  List<dynamic>? attachments;
  String? createdAt;
  String? updatedAt;
  int? v;
  String? status;

  Data1({
    this.id,
    this.employeeId,
    this.employeeName,
    this.empId,
    this.companyId,
    this.branchId,
    this.policyId,
    this.requestType,
    this.subType,
    this.requestData,
    this.approvers,
    this.reason,
    this.attachments,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.status,
  });

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
    requestData = json["requestData"] != null
        ? (json["requestData"] as List).map((e) => RequestData.fromJson(e)).toList()
        : [];
    approvers = json["approvers"] != null
        ? (json["approvers"] as List).map((e) => Approvers.fromJson(e)).toList()
        : [];
    reason = json["reason"];
    attachments = json["attachments"] ?? [];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
    status = json["status"];
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "employeeId": employeeId,
      "employeeName": employeeName,
      "empId": empId,
      "companyId": companyId,
      "branchId": branchId,
      "policyId": policyId,
      "requestType": requestType,
      "subType": subType,
      "requestData": requestData?.map((e) => e.toJson()).toList(),
      "approvers": approvers?.map((e) => e.toJson()).toList(),
      "reason": reason,
      "attachments": attachments,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "__v": v,
      "status": status,
    };
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
    return {
      "approverId": approverId,
      "approverName": approverName,
      "isRequired": isRequired,
      "status": status,
      "timeStamps": timeStamps,
      "comments": comments,
    };
  }
}

class RequestData {
  List<Employees>? employees;
  String? finePenality;
  int? amount;
  String? details;
  String? remark;
  String? date;

  RequestData({this.employees, this.finePenality, this.amount, this.details, this.remark, this.date});

  RequestData.fromJson(Map<String, dynamic> json) {
    employees = json["employees"] != null
        ? (json["employees"] as List).map((e) => Employees.fromJson(e)).toList()
        : [];
    finePenality = json["fine_penality"];
    amount = json["amount"];
    details = json["details"];
    remark = json["remark"];
    date = json["date"];
  }

  Map<String, dynamic> toJson() {
    return {
      "employees": employees?.map((e) => e.toJson()).toList(),
      "fine_penality": finePenality,
      "amount": amount,
      "details": details,
      "remark": remark,
      "date": date,
    };
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
    return {
      "empId": empId,
      "name": name,
      "severity": severity,
    };
  }
}
