class TaskModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  List<Dattaa>? data;

  TaskModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  TaskModel.fromJson(Map<String, dynamic> json) {
    statusCode = json["statusCode"];
    statusMessage = json["statusMessage"];
    errorMessage = json["errorMessage"];
    data = json["data"] == null ? null : (json["data"] as List).map((e) => Dattaa.fromJson(e)).toList();
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
  List<ReportedTo>? reportedTo;
  List<LogDuration>? logDuration;
  List<String>? subTask;
  List<Comments>? comments;
  String? createdAt;
  String? updatedAt;
  int? v;

  Dattaa({this.id, this.projectId, this.subject, this.taskId, this.description, this.attachments, this.status, this.estimatedDuration, this.type, this.tag, this.assignTo, this.reportedTo, this.logDuration, this.subTask, this.comments, this.createdAt, this.updatedAt, this.v});

  Dattaa.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    projectId = json["projectId"];
    subject = json["subject"];
    taskId = json["taskId"];
    description = json["description"];
    attachments = json["attachments"];
    status = json["status"];
    estimatedDuration = json["estimatedDuration"];
    type = json["type"];
    tag = json["tag"] == null ? null : List<String>.from(json["tag"]);
    assignTo = json["assignTo"] == null ? null : List<String>.from(json["assignTo"]);
    reportedTo = json["reportedTo"] == null ? null : (json["reportedTo"] as List).map((e) => ReportedTo.fromJson(e)).toList();
    logDuration = json["logDuration"] == null ? null : (json["logDuration"] as List).map((e) => LogDuration.fromJson(e)).toList();
    subTask = json["subTask"] == null ? null : List<String>.from(json["subTask"]);
    comments = json["comments"] == null ? null : (json["comments"] as List).map((e) => Comments.fromJson(e)).toList();
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["projectId"] = projectId;
    _data["subject"] = subject;
    _data["taskId"] = taskId;
    _data["description"] = description;
    _data["attachments"] = attachments;
    _data["status"] = status;
    _data["estimatedDuration"] = estimatedDuration;
    _data["type"] = type;
    if(tag != null) {
      _data["tag"] = tag;
    }
    if(assignTo != null) {
      _data["assignTo"] = assignTo;
    }
    if(reportedTo != null) {
      _data["reportedTo"] = reportedTo?.map((e) => e.toJson()).toList();
    }
    if(logDuration != null) {
      _data["logDuration"] = logDuration?.map((e) => e.toJson()).toList();
    }
    if(subTask != null) {
      _data["subTask"] = subTask;
    }
    if(comments != null) {
      _data["comments"] = comments?.map((e) => e.toJson()).toList();
    }
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    return _data;
  }
}

class Comments {
  String? comments;
  String? commentedBy;
  String? commentedAt;

  Comments({this.comments, this.commentedBy, this.commentedAt});

  Comments.fromJson(Map<String, dynamic> json) {
    comments = json["comments"];
    commentedBy = json["commentedBy"];
    commentedAt = json["commentedAt"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["comments"] = comments;
    _data["commentedBy"] = commentedBy;
    _data["commentedAt"] = commentedAt;
    return _data;
  }
}

class LogDuration {
  String? date;
  String? hours;
  String? description;
  String? loggedBy;

  LogDuration({this.date, this.hours, this.description, this.loggedBy});

  LogDuration.fromJson(Map<String, dynamic> json) {
    date = json["date"];
    hours = json["hours"];
    description = json["description"];
    loggedBy = json["loggedBy"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["date"] = date;
    _data["hours"] = hours;
    _data["description"] = description;
    _data["loggedBy"] = loggedBy;
    return _data;
  }
}

class ReportedTo {
  String? manager;

  ReportedTo({this.manager});

  ReportedTo.fromJson(Map<String, dynamic> json) {
    manager = json["manager"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["manager"] = manager;
    return _data;
  }
}