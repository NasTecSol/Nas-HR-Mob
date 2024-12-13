class ProfileResponse {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  Data? data;

  ProfileResponse({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  ProfileResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json["statusCode"];
    statusMessage = json["statusMessage"];
    errorMessage = json["errorMessage"];
    data = json["data"] != null ? Data.fromJson(json["data"]) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["statusCode"] = statusCode;
    _data["statusMessage"] = statusMessage;
    _data["errorMessage"] = errorMessage;
    _data["data"] = data?.toJson();
    return _data;
  }
}

class Data {
  String? attachmentId;
  String? attachmentName;
  String? attachmentType;
  String? url;
  String? id;
  String? createdAt;
  String? updatedAt;
  int? v;

  Data({
    this.attachmentId,
    this.attachmentName,
    this.attachmentType,
    this.url,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  Data.fromJson(Map<String, dynamic> json) {
    attachmentId = json["attachmentId"];
    attachmentName = json["attachmentName"];
    attachmentType = json["attachmentType"];
    url = json["url"];
    id = json["_id"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["attachmentId"] = attachmentId;
    _data["attachmentName"] = attachmentName;
    _data["attachmentType"] = attachmentType;
    _data["url"] = url;
    _data["_id"] = id;
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    return _data;
  }
}
