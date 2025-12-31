class CompanyNotificationModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  List<Data>? data;

  CompanyNotificationModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  CompanyNotificationModel.fromJson(Map<String, dynamic> json) {
    statusCode = json["statusCode"];
    statusMessage = json["statusMessage"];
    errorMessage = json["errorMessage"];
    data = json["data"] == null ? null : (json["data"] as List).map((e) => Data.fromJson(e)).toList();
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
  String? companyId;
  String? branchId;
  String? attachmentName;
  String? attachmentUrl;
  String? expiryDate;
  String? objectType;
  String? objectId;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? v;
  dynamic notifcationPeriod;
  dynamic notificationBegins;

  Data({this.id, this.companyId, this.branchId, this.attachmentName, this.attachmentUrl, this.expiryDate, this.objectType, this.objectId, this.status, this.createdAt, this.updatedAt, this.v, this.notifcationPeriod, this.notificationBegins});

  Data.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    companyId = json["companyId"];
    branchId = json["branchId"];
    attachmentName = json["attachmentName"];
    attachmentUrl = json["attachmentURL"];
    expiryDate = json["expiryDate"];
    objectType = json["objectType"];
    objectId = json["objectId"];
    status = json["status"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
    notifcationPeriod = json["notifcationPeriod"];
    notificationBegins = json["notificationBegins"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["companyId"] = companyId;
    _data["branchId"] = branchId;
    _data["attachmentName"] = attachmentName;
    _data["attachmentURL"] = attachmentUrl;
    _data["expiryDate"] = expiryDate;
    _data["objectType"] = objectType;
    _data["objectId"] = objectId;
    _data["status"] = status;
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    _data["notifcationPeriod"] = notifcationPeriod;
    _data["notificationBegins"] = notificationBegins;
    return _data;
  }
}