class TaskModel {
  int? statusCode;
  String? statusMessage;
  String? errorMessage;
  List<Dattaa>? data;

  TaskModel({
    this.statusCode,
    this.statusMessage,
    this.errorMessage,
    this.data,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      statusCode: json['statusCode'],
      statusMessage: json['statusMessage'],
      errorMessage: json['errorMessage'],
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Dattaa.fromJson(e))
          .toList(),
    );
  }
}

class Dattaa {
  String? id;
  String? projectId;
  String? subject;
  String? taskId;
  String? description;
  String? attachments;
  String? status;
  String? estimatedDuration;
  String? type;
  List<String>? tag;
  List<String>? assignTo;
  ReportedTo? reportedTo;
  List<LogDuration>? logDuration;
  List<String>? subTask;
  List<Comment>? comments;
  String? createdAt;
  String? updatedAt;
  int? v;

  Dattaa({
    this.id,
    this.projectId,
    this.subject,
    this.taskId,
    this.description,
    this.attachments,
    this.status,
    this.estimatedDuration,
    this.type,
    this.tag,
    this.assignTo,
    this.reportedTo,
    this.logDuration,
    this.subTask,
    this.comments,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Dattaa.fromJson(Map<String, dynamic> json) {
    return Dattaa(
      id: json['_id'],
      projectId: json['projectId'],
      subject: json['subject'],
      taskId: json['taskId'],
      description: json['description'],
      attachments: json['attachments'],
      status: json['status'],
      estimatedDuration: json['estimatedDuration'],
      type: json['type'],
      tag: (json['tag'] is List)
          ? List<String>.from(json['tag'])
          : [],
      assignTo: (json['assignTo'] is List)
          ? List<String>.from(json['assignTo'])
          : [],
      reportedTo: json['reportedTo'] != null
          ? ReportedTo.fromJson(json['reportedTo'])
          : null,
      logDuration: (json['logDuration'] is List)
          ? (json['logDuration'] as List)
          .map((e) => LogDuration.fromJson(e))
          .toList()
          : [],
      subTask: (json['subTask'] is List)
          ? List<String>.from(json['subTask'])
          : [],
      comments: (json['comments'] is List)
          ? (json['comments'] as List)
          .map((e) => Comment.fromJson(e))
          .toList()
          : [],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }
}

class ReportedTo {
  String? manager;

  ReportedTo({this.manager});

  factory ReportedTo.fromJson(Map<String, dynamic> json) {
    return ReportedTo(
      manager: json['manager'],
    );
  }
}

class LogDuration {
  String? date;
  String? hours;
  String? description;
  String? loggedBy;

  LogDuration({
    this.date,
    this.hours,
    this.description,
    this.loggedBy,
  });

  factory LogDuration.fromJson(Map<String, dynamic> json) {
    return LogDuration(
      date: json['date'],
      hours: json['hours'],
      description: json['description'],
      loggedBy: json['loggedBy'],
    );
  }
}

class Comment {
  String? comments;
  String? commentedBy;
  String? commentedAt;

  Comment({
    this.comments,
    this.commentedBy,
    this.commentedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      comments: json['comments'],
      commentedBy: json['commentedBy'],
      commentedAt: json['commentedAt'],
    );
  }
}
