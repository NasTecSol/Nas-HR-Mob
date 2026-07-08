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
  List<AssignTo>? assignTo;
  List<ReportedTo>? reportedTo;
  List<LogDuration>? logDuration;
  List<String>? subTask;
  List<Comments>? comments;
  String? createdAt;
  String? updatedAt;
  int? v;

  Dattaa({this.id, this.projectId, this.subject, this.taskId, this.description, this.attachments, this.status, this.estimatedDuration, this.type, this.tag, this.assignTo, this.reportedTo, this.logDuration, this.subTask, this.comments, this.createdAt, this.updatedAt, this.v});

  Dattaa.fromJson(Map<String, dynamic> json) {
    id = json["_id"]?.toString();
    projectId = json["projectId"]?.toString();
    subject = json["subject"]?.toString();
    taskId = json["taskId"]?.toString();
    description = json["description"]?.toString();
    
    if (json["attachments"] is List) {
      attachments = (json["attachments"] as List).join(", ");
    } else {
      attachments = json["attachments"]?.toString();
    }
    
    status = json["status"]?.toString();
    estimatedDuration = json["estimatedDuration"]?.toString();
    type = json["type"]?.toString();
    
    if (json["tag"] is List) {
      tag = List<String>.from((json["tag"] as List).map((e) => e.toString()));
    } else if (json["tag"] is String) {
      tag = [json["tag"] as String];
    } else {
      tag = null;
    }
    
    if (json["assignTo"] is List) {
      assignTo = (json["assignTo"] as List).map((e) => AssignTo.fromJson(e)).toList();
    } else {
      assignTo = null;
    }
    
    if (json["reportedTo"] is List) {
      reportedTo = (json["reportedTo"] as List).map((e) => ReportedTo.fromJson(e)).toList();
    } else if (json["reportedTo"] is Map) {
      reportedTo = [ReportedTo.fromJson(Map<String, dynamic>.from(json["reportedTo"]))];
    } else if (json["reportedTo"] is String) {
      reportedTo = [ReportedTo(manager: json["reportedTo"] as String)];
    } else {
      reportedTo = null;
    }
    
    if (json["logDuration"] is List) {
      logDuration = (json["logDuration"] as List).map((e) => LogDuration.fromJson(e)).toList();
    } else {
      logDuration = null;
    }
    
    if (json["subTask"] is List) {
      subTask = List<String>.from((json["subTask"] as List).map((e) => e.toString()));
    } else {
      subTask = null;
    }
    
    if (json["comments"] is List) {
      comments = (json["comments"] as List).map((e) => Comments.fromJson(e)).toList();
    } else {
      comments = null;
    }
    
    createdAt = json["createdAt"]?.toString();
    updatedAt = json["updatedAt"]?.toString();
    v = json["__v"] is int ? json["__v"] as int : null;
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
      _data["assignTo"] = assignTo?.map((e) => e.toJson()).toList();
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
    manager = _parseManager(json["manager"]);
  }

  static String? _parseManager(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) {
      if (value.containsKey("managerName") && value["managerName"] != null) {
        return value["managerName"].toString();
      }
      if (value.containsKey("managerId") && value["managerId"] != null) {
        return value["managerId"].toString();
      }
      if (value.containsKey("manager")) {
        return _parseManager(value["manager"]);
      }
    }
    if (value is List) {
      for (var item in value) {
        final parsed = _parseManager(item);
        if (parsed != null) return parsed;
      }
    }
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["manager"] = manager;
    return _data;
  }
}

class AssignTo {
  String? userId;
  String? userName;

  AssignTo({this.userId, this.userName});

  AssignTo.fromJson(Map<String, dynamic> json) {
    userId = json["userId"];
    userName = json["userName"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["userId"] = userId;
    _data["userName"] = userName;
    return _data;
  }
}