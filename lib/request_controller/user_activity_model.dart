
class UserActivityModel {
  dynamic id;
  dynamic empId;
  dynamic attendanceId;
  dynamic date;
  List<ActivitySession>? activitySession;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic v;
  Body? body;
  dynamic expiryAt;

  UserActivityModel({this.id, this.empId, this.attendanceId, this.date, this.activitySession, this.createdAt, this.updatedAt, this.v, this.body, this.expiryAt});

  UserActivityModel.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    empId = json["empId"];
    attendanceId = json["attendanceId"];
    date = json["date"];
    activitySession = json["activitySession"] == null ? null : (json["activitySession"] as List).map((e) => ActivitySession.fromJson(e)).toList();
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
    body = json["body"] == null ? null : Body.fromJson(json["body"]);
    expiryAt = json["expiryAt"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["empId"] = empId;
    _data["attendanceId"] = attendanceId;
    _data["date"] = date;
    if(activitySession != null) {
      _data["activitySession"] = activitySession?.map((e) => e.toJson()).toList();
    }
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    if(body != null) {
      _data["body"] = body?.toJson();
    }
    _data["expiryAt"] = expiryAt;
    return _data;
  }
}

class Body {
  dynamic idleTimeMs;
  dynamic activeTimeMs;
  dynamic totalTimeMs;
  List<String>? mostUsedApps;
  List<String>? leastUsedApps;
  TaskNameWiseTime? taskNameWiseTime;
  List<String>? listOfAllAppsUsed;
  List<String>? listOfAllTaskNamesUsed;

  Body({this.idleTimeMs, this.activeTimeMs, this.totalTimeMs, this.mostUsedApps, this.leastUsedApps, this.taskNameWiseTime, this.listOfAllAppsUsed, this.listOfAllTaskNamesUsed});

  Body.fromJson(Map<String, dynamic> json) {
    idleTimeMs = json["idleTimeMs"];
    activeTimeMs = json["activeTimeMs"];
    totalTimeMs = json["totalTimeMs"];
    mostUsedApps = json["mostUsedApps"] == null ? null : List<String>.from(json["mostUsedApps"]);
    leastUsedApps = json["leastUsedApps"] == null ? null : List<String>.from(json["leastUsedApps"]);
    taskNameWiseTime = json["taskNameWiseTime"] == null ? null : TaskNameWiseTime.fromJson(json["taskNameWiseTime"]);
    listOfAllAppsUsed = json["listOfAllAppsUsed"] == null ? null : List<String>.from(json["listOfAllAppsUsed"]);
    listOfAllTaskNamesUsed = json["listOfAllTaskNamesUsed"] == null ? null : List<String>.from(json["listOfAllTaskNamesUsed"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["idleTimeMs"] = idleTimeMs;
    _data["activeTimeMs"] = activeTimeMs;
    _data["totalTimeMs"] = totalTimeMs;
    if(mostUsedApps != null) {
      _data["mostUsedApps"] = mostUsedApps;
    }
    if(leastUsedApps != null) {
      _data["leastUsedApps"] = leastUsedApps;
    }
    if(taskNameWiseTime != null) {
      _data["taskNameWiseTime"] = taskNameWiseTime?.toJson();
    }
    if(listOfAllAppsUsed != null) {
      _data["listOfAllAppsUsed"] = listOfAllAppsUsed;
    }
    if(listOfAllTaskNamesUsed != null) {
      _data["listOfAllTaskNamesUsed"] = listOfAllTaskNamesUsed;
    }
    return _data;
  }
}

class TaskNameWiseTime {
  dynamic unknown;

  TaskNameWiseTime({this.unknown});

  TaskNameWiseTime.fromJson(Map<String, dynamic> json) {
    unknown = json["unknown"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["unknown"] = unknown;
    return _data;
  }
}

class ActivitySession {
  dynamic id;
  dynamic app;
  dynamic taskName;
  dynamic title;
  dynamic url;
  dynamic color;
  dynamic beginDate;
  dynamic endDate;

  ActivitySession({this.id, this.app, this.taskName, this.title, this.url, this.color, this.beginDate, this.endDate});

  ActivitySession.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    app = json["app"];
    taskName = json["taskName"];
    title = json["title"];
    url = json["url"];
    color = json["color"];
    beginDate = json["beginDate"];
    endDate = json["endDate"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["app"] = app;
    _data["taskName"] = taskName;
    _data["title"] = title;
    _data["url"] = url;
    _data["color"] = color;
    _data["beginDate"] = beginDate;
    _data["endDate"] = endDate;
    return _data;
  }
}
