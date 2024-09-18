
class ApproverRequestData {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  List<Data>? data;

  ApproverRequestData({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  ApproverRequestData.fromJson(Map<String, dynamic> json) {
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

  Data({this.id, this.employeeId, this.employeeName, this.companyId, this.branchId, this.policyId, this.requestType, this.subType, this.requestData, this.approvers, this.reason, this.attachments, this.createdAt, this.updatedAt, this.v, this.status});

  Data.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    employeeId = json["employeeId"];
    employeeName = json["employeeName"];
    companyId = json["companyId"];
    branchId = json["branchId"];
    policyId = json["policyId"];
    requestType = json["requestType"];
    subType = json["subType"];
    requestData = json["requestData"] == null ? null : (json["requestData"] as List).map((e) => RequestData.fromJson(e)).toList();
    approvers = json["approvers"] == null ? null : (json["approvers"] as List).map((e) => Approvers.fromJson(e)).toList();
    reason = json["reason"];
    attachments = json["attachments"] ?? [];
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
      _data["attachments"] = attachments;
    }
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    _data["status"] = status;
    return _data;
  }
}

class Approvers {
  String? approverId;
  String? approverName;
  String? status;
  String? timeStamps;
  String? comments;

  Approvers({this.approverId, this.approverName, this.status, this.timeStamps, this.comments});

  Approvers.fromJson(Map<String, dynamic> json) {
    approverId = json["approverId"];
    approverName = json["approverName"];
    status = json["status"];
    timeStamps = json["timeStamps"];
    comments = json["comments"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["approverId"] = approverId;
    _data["approverName"] = approverName;
    _data["status"] = status;
    _data["timeStamps"] = timeStamps;
    _data["comments"] = comments;
    return _data;
  }
}

class RequestData {
  String? startDate;
  String? endDate;
  String? duration;
  String? leaveType;

  RequestData({this.startDate, this.endDate, this.duration, this.leaveType});

  RequestData.fromJson(Map<String, dynamic> json) {
    startDate = json["start_date"];
    endDate = json["end_date"];
    duration = json["duration"];
    leaveType = json["leave_type"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["start_date"] = startDate;
    _data["end_date"] = endDate;
    _data["duration"] = duration;
    _data["leave_type"] = leaveType;
    return _data;
  }
}