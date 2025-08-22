class SocketModel {
  final String messageEn;
  final String messageAr;
  final String module;
  final dynamic data; // can be AttendanceLog OR RequestData
  final dynamic targetAudience; // can be List or Map depending on API
  final DateTime timestamp;

  SocketModel({
    required this.messageEn,
    required this.messageAr,
    required this.module,
    required this.data,
    required this.targetAudience,
    required this.timestamp,
  });

  factory SocketModel.fromJson(Map<String, dynamic> json) {
    dynamic parsedData;

    if (json['data'] != null) {
      // If data contains "log", it's AttendanceLog
      if (json['data'] is Map<String, dynamic> &&
          json['data'].containsKey('log')) {
        parsedData = AttendanceLog.fromJson(json['data']['log']);
      }
      // Otherwise assume it's RequestData
      else if (json['data'] is Map<String, dynamic>) {
        parsedData = RequestData.fromJson(json['data']);
      }
    }

    return SocketModel(
      messageEn: json['message']?['en'] ?? '',
      messageAr: json['message']?['ar'] ?? '',
      module: json['module'] ?? '',
      data: parsedData,
      targetAudience: json['targetAudience'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}


class RequestData {
  final String employeeId;
  final String employeeName;
  final String empId;
  final String companyId;
  final String branchId;
  final String policyId;
  final String requestType;
  final String subType;
  final List<RequestField> requestData;
  final List<Approver> approvers;
  final String reason;
  final List<dynamic> attachments;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;
  final String status;

  RequestData({
    required this.employeeId,
    required this.employeeName,
    required this.empId,
    required this.companyId,
    required this.branchId,
    required this.policyId,
    required this.requestType,
    required this.subType,
    required this.requestData,
    required this.approvers,
    required this.reason,
    required this.attachments,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.status,
  });

  factory RequestData.fromJson(Map<String, dynamic> json) {
    return RequestData(
      employeeId: json['employeeId'] ?? '',
      employeeName: json['employeeName'] ?? '',
      empId: json['empId'] ?? '',
      companyId: json['companyId'] ?? '',
      branchId: json['branchId'] ?? '',
      policyId: json['policyId'] ?? '',
      requestType: json['requestType'] ?? '',
      subType: json['subType'] ?? '',
      requestData: (json['requestData'] as List? ?? [])
          .map((e) => RequestField.fromJson(e))
          .toList(),
      approvers: (json['approvers'] as List? ?? [])
          .map((e) => Approver.fromJson(e))
          .toList(),
      reason: json['reason'] ?? '',
      attachments: json['attachments'] ?? [],
      id: json['_id'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      v: json['__v'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}

class RequestField {
  final String title;
  final String message;

  RequestField({required this.title, required this.message});

  factory RequestField.fromJson(Map<String, dynamic> json) {
    return RequestField(
      title: json['title'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

class Approver {
  final String approverId;
  final String approverName;
  final bool isRequired;
  final String status;
  final DateTime timeStamps;
  final String? comments;

  Approver({
    required this.approverId,
    required this.approverName,
    required this.isRequired,
    required this.status,
    required this.timeStamps,
    this.comments,
  });

  factory Approver.fromJson(Map<String, dynamic> json) {
    return Approver(
      approverId: json['approverId'] ?? '',
      approverName: json['approverName'] ?? '',
      isRequired: json['isRequired'] ?? false,
      status: json['status'] ?? '',
      timeStamps: DateTime.tryParse(json['timeStamps'] ?? '') ?? DateTime.now(),
      comments: json['comments'],
    );
  }
}
class RawBiometric {
  final DateTime timestamp;
  final String type;

  RawBiometric({required this.timestamp, required this.type});

  factory RawBiometric.fromJson(Map<String, dynamic> json) {
    return RawBiometric(
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
    );
  }
}

class AttendanceLog {
  final String id;
  final String empId;
  final String employeeId;
  final String employeeName;
  final DateTime checkInTime;
  final DateTime checkOutTime;
  final String type;
  final String? totalTime;
  final String date;
  final String status;
  final DateTime lastProcessedRecord;
  final List<RawBiometric> rawBiometrics;
  final DateTime createdAt;
  final DateTime updatedAt;

  AttendanceLog({
    required this.id,
    required this.empId,
    required this.employeeId,
    required this.employeeName,
    required this.checkInTime,
    required this.checkOutTime,
    required this.type,
    this.totalTime,
    required this.date,
    required this.status,
    required this.lastProcessedRecord,
    required this.rawBiometrics,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendanceLog.fromJson(Map<String, dynamic> json) {
    return AttendanceLog(
      id: json['_id'],
      empId: json['empId'],
      employeeId: json['employeeId'],
      employeeName: json['employeeName'],
      checkInTime: DateTime.parse(json['checkInTime']),
      checkOutTime: DateTime.parse(json['checkOutTime']),
      type: json['type'],
      totalTime: json['totalTime'],
      date: json['date'],
      status: json['status'],
      lastProcessedRecord: DateTime.parse(json['lastProcessedRecord']),
      rawBiometrics: (json['rawBiometrics'] as List)
          .map((e) => RawBiometric.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
