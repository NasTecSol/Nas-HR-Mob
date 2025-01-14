
class ProjectsData {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  List<Data>? data;

  ProjectsData({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  ProjectsData.fromJson(Map<String, dynamic> json) {
    statusCode = json["statusCode"];
    statusMessage = json["statusMessage"];
    errorMessage = json["errorMessage"];
    data = json["data"] == null ? [] : (json["data"] as List).map((e) => Data.fromJson(e)).toList();
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
  String? name;
  String? description;
  String? teamId;
  String? teamName;
  List<ProjectMembers>? projectMembers;
  String? projectLocation;
  String? type;
  String? logo;
  String? projectKey;
  String? adminId;
  List<String>? columnsStatus;
  BoardConfig? boardConfig;
  String? createdAt;
  String? updatedAt;
  int? v;

  Data({this.id, this.name, this.description, this.teamId, this.teamName, this.projectMembers, this.projectLocation, this.type, this.logo, this.projectKey, this.adminId, this.columnsStatus, this.boardConfig, this.createdAt, this.updatedAt, this.v});

  Data.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    name = json["name"];
    description = json["description"];
    teamId = json["teamId"];
    teamName = json["teamName"];
    projectMembers = json["projectMembers"] == null ? null : (json["projectMembers"] as List).map((e) => ProjectMembers.fromJson(e)).toList();
    projectLocation = json["projectLocation"];
    type = json["type"];
    logo = json["logo"];
    projectKey = json["projectKey"];
    adminId = json["adminId"];
    columnsStatus = json["columns_status"] == null ? null : List<String>.from(json["columns_status"]);
    boardConfig = json["boardConfig"] == null ? null : BoardConfig.fromJson(json["boardConfig"]);
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["name"] = name;
    _data["description"] = description;
    _data["teamId"] = teamId;
    _data["teamName"] = teamName;
    if(projectMembers != null) {
      _data["projectMembers"] = projectMembers?.map((e) => e.toJson()).toList();
    }
    _data["projectLocation"] = projectLocation;
    _data["type"] = type;
    _data["logo"] = logo;
    _data["projectKey"] = projectKey;
    _data["adminId"] = adminId;
    if(columnsStatus != null) {
      _data["columns_status"] = columnsStatus;
    }
    if(boardConfig != null) {
      _data["boardConfig"] = boardConfig?.toJson();
    }
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    return _data;
  }
}

class BoardConfig {
  List<Statuses>? statuses;
  List<Columns>? column;

  BoardConfig({this.statuses, this.column});

  BoardConfig.fromJson(Map<String, dynamic> json) {
    statuses = json["statuses"] == null ? null : (json["statuses"] as List).map((e) => Statuses.fromJson(e)).toList();
    column = json["column"] == null ? null : (json["column"] as List).map((e) => Columns.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if(statuses != null) {
      _data["statuses"] = statuses?.map((e) => e.toJson()).toList();
    }
    if(column != null) {
      _data["column"] = column?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Columns {
  String? id;
  String? name;
  String? statusId;

  Columns({this.id, this.name, this.statusId});

  Columns.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    statusId = json["statusId"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["name"] = name;
    _data["statusId"] = statusId;
    return _data;
  }
}

class Statuses {
  String? id;
  String? name;
  String? color;

  Statuses({this.id, this.name, this.color});

  Statuses.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    color = json["color"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["name"] = name;
    _data["color"] = color;
    return _data;
  }
}

class ProjectMembers {
  String? empId;
  String? name;
  String? employeeId;
  String? designation;
  String? accessLevels;

  ProjectMembers({this.name, this.employeeId, this.empId, this.designation, this.accessLevels});

  ProjectMembers.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    employeeId = json["employeeId"];
    empId = json["empId"];
    designation = json["designation"];
    accessLevels = json["accessLevels"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["name"] = name;
    _data["employeeId"] = employeeId;
    _data["empId"] = empId;
    _data["designation"] = designation;
    _data["accessLevels"] = accessLevels;
    return _data;
  }
}