
class UserActivityModel {
  String? id;
  String? empId;
  String? attendanceId;
  String? date;
  String? expiryAt;
  String? createdAt;
  String? updatedAt;
  int? v;
  Body? body;

  UserActivityModel({this.id, this.empId, this.attendanceId, this.date, this.expiryAt, this.createdAt, this.updatedAt, this.v, this.body});

  UserActivityModel.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    empId = json["empId"];
    attendanceId = json["attendanceId"];
    date = json["date"];
    expiryAt = json["expiryAt"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
    body = json["body"] == null ? null : Body.fromJson(json["body"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["empId"] = empId;
    _data["attendanceId"] = attendanceId;
    _data["date"] = date;
    _data["expiryAt"] = expiryAt;
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    if(body != null) {
      _data["body"] = body?.toJson();
    }
    return _data;
  }
}

class Body {
  int? idleTimeMs;
  int? activeTimeMs;
  int? totalTimeMs;
  List<String>? mostUsedApps;
  List<String>? leastUsedApps;
  TaskNameWiseTime? taskNameWiseTime;
  List<String>? listOfAllAppsUsed;
  List<dynamic>? listOfAllTaskNamesUsed;

  Body({this.idleTimeMs, this.activeTimeMs, this.totalTimeMs, this.mostUsedApps, this.leastUsedApps, this.taskNameWiseTime, this.listOfAllAppsUsed, this.listOfAllTaskNamesUsed});

  Body.fromJson(Map<String, dynamic> json) {
    idleTimeMs = json["idleTimeMs"];
    activeTimeMs = json["activeTimeMs"];
    totalTimeMs = json["totalTimeMs"];
    mostUsedApps = json["mostUsedApps"] == null ? null : List<String>.from(json["mostUsedApps"]);
    leastUsedApps = json["leastUsedApps"] == null ? null : List<String>.from(json["leastUsedApps"]);
    taskNameWiseTime = json["taskNameWiseTime"] == null ? null : TaskNameWiseTime.fromJson(json["taskNameWiseTime"]);
    listOfAllAppsUsed = json["listOfAllAppsUsed"] == null ? null : List<String>.from(json["listOfAllAppsUsed"]);
    listOfAllTaskNamesUsed = json["listOfAllTaskNamesUsed"] ?? [];
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
  TaskNameWiseTime();

  TaskNameWiseTime.fromJson(Map<String, dynamic> json) {

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};

    return _data;
  }
}
