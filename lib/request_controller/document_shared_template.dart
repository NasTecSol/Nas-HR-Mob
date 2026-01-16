class DocumentSharedTemplate {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  Data? data;

  DocumentSharedTemplate({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  DocumentSharedTemplate.fromJson(Map<String, dynamic> json) {
    statusCode = json["statusCode"];
    statusMessage = json["statusMessage"];
    errorMessage = json["errorMessage"];
    data = json["data"] == null ? null : Data.fromJson(json["data"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["statusCode"] = statusCode;
    _data["statusMessage"] = statusMessage;
    _data["errorMessage"] = errorMessage;
    if(data != null) {
      _data["data"] = data?.toJson();
    }
    return _data;
  }
}

class Data {
  List<Data1>? data;
  int? totalRecords;
  int? page;
  int? limit;
  int? totalPages;

  Data({this.data, this.totalRecords, this.page, this.limit, this.totalPages});

  Data.fromJson(Map<String, dynamic> json) {
    data = json["data"] == null ? null : (json["data"] as List).map((e) => Data1.fromJson(e)).toList();
    totalRecords = json["totalRecords"];
    page = json["page"];
    limit = json["limit"];
    totalPages = json["totalPages"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if(data != null) {
      _data["data"] = data?.map((e) => e.toJson()).toList();
    }
    _data["totalRecords"] = totalRecords;
    _data["page"] = page;
    _data["limit"] = limit;
    _data["totalPages"] = totalPages;
    return _data;
  }
}

class Data1 {
  String? id;
  String? templateType;
  ObjectDetails? objectDetails;
  int? v;

  Data1({this.id, this.templateType, this.objectDetails, this.v});

  Data1.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    templateType = json["templateType"];
    objectDetails = json["objectDetails"] == null ? null : ObjectDetails.fromJson(json["objectDetails"]);
    v = json["__v"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["templateType"] = templateType;
    if(objectDetails != null) {
      _data["objectDetails"] = objectDetails?.toJson();
    }
    _data["__v"] = v;
    return _data;
  }
}

class ObjectDetails {
  String? type;
  String? objectName;
  String? objectIcon;
  Parameters? parameters;
  String? createdBy;

  ObjectDetails({this.type, this.objectName, this.objectIcon, this.parameters, this.createdBy});

  ObjectDetails.fromJson(Map<String, dynamic> json) {
    type = json["Type"];
    objectName = json["objectName"];
    objectIcon = json["objectIcon"];
    parameters = json["parameters"] == null ? null : Parameters.fromJson(json["parameters"]);
    createdBy = json["createdBy"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["Type"] = type;
    _data["objectName"] = objectName;
    _data["objectIcon"] = objectIcon;
    if(parameters != null) {
      _data["parameters"] = parameters?.toJson();
    }
    _data["createdBy"] = createdBy;
    return _data;
  }
}

class Parameters {
  String? documentUrl;
  List<String>? employees;

  Parameters({this.documentUrl, this.employees});

  Parameters.fromJson(Map<String, dynamic> json) {
    documentUrl = json["documentUrl"];
    employees = json["employees"] == null ? null : List<String>.from(json["employees"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["documentUrl"] = documentUrl;
    if(employees != null) {
      _data["employees"] = employees;
    }
    return _data;
  }
}