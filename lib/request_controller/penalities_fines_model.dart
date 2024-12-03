
class PenaltiesAndFineModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  List<Data>? data;

  PenaltiesAndFineModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  PenaltiesAndFineModel.fromJson(Map<String, dynamic> json) {
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

  Data({this.id, this.employeeId, this.employeeName, this.empId, this.companyId, this.branchId, this.policyId, this.requestType, this.subType, this.requestData, this.approvers, this.reason, this.attachments, this.createdAt, this.updatedAt, this.v, this.status});

  Data.fromJson(Map<String, dynamic> json) {
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
  String? type;
  String? url;

  Attachments({this.type, this.url});

  Attachments.fromJson(Map<String, dynamic> json) {
    type = json["type"];
    url = json["url"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["type"] = type;
    _data["url"] = url;
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
  List<Employees>? employees;
  String? finePenality;
  int? amount;
  String? details;
  String? remark;
  String? date;

  RequestData({this.employees, this.finePenality, this.amount, this.details, this.remark, this.date});

  RequestData.fromJson(Map<String, dynamic> json) {
    employees = json["employees"] == null ? null : (json["employees"] as List).map((e) => Employees.fromJson(e)).toList();
    finePenality = json["fine_penality"];
    amount = json["amount"];
    details = json["details"];
    remark = json["remark"];
    date = json["date"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if(employees != null) {
      _data["employees"] = employees?.map((e) => e.toJson()).toList();
    }
    _data["fine_penality"] = finePenality;
    _data["amount"] = amount;
    _data["details"] = details;
    _data["remark"] = remark;
    _data["date"] = date;
    return _data;
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
