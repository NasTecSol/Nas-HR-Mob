class SocketModel {
  final String messageEn;
  final String messageAr;
  final String module;
  final AttendanceLog data;
  final Map<String, dynamic> targetAudience;
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
    return SocketModel(
      messageEn: json['message']['en'],
      messageAr: json['message']['ar'],
      module: json['module'],
      data: AttendanceLog.fromJson(json['data']['log']),
      targetAudience: json['targetAudience'],
      timestamp: DateTime.parse(json['timestamp']),
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
