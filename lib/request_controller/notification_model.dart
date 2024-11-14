
class NotificationModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  List<Data>? data;

  NotificationModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  NotificationModel.fromJson(Map<String, dynamic> json) {
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
  String? notificationType;
  String? message;
  String? title;
  String? metaData;
  List<From>? from;
  List<To>? to;
  String? notificationMessage;
  String? status;
  String? requestId;
  String? createdAt;
  String? updatedAt;
  int? v;

  Data({this.id, this.notificationType, this.message, this.title, this.metaData, this.from, this.to, this.notificationMessage, this.status, this.requestId, this.createdAt, this.updatedAt, this.v});

  Data.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    notificationType = json["notificationType"];
    message = json["message"];
    title = json["title"];
    metaData = json["metaData"];
    from = json["from"] == null ? null : (json["from"] as List).map((e) => From.fromJson(e)).toList();
    to = json["to"] == null ? null : (json["to"] as List).map((e) => To.fromJson(e)).toList();
    notificationMessage = json["notificationMessage"];
    status = json["status"];
    requestId = json["requestId"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["notificationType"] = notificationType;
    _data["message"] = message;
    _data["title"] = title;
    _data["metaData"] = metaData;
    if(from != null) {
      _data["from"] = from?.map((e) => e.toJson()).toList();
    }
    if(to != null) {
      _data["to"] = to?.map((e) => e.toJson()).toList();
    }
    _data["notificationMessage"] = notificationMessage;
    _data["status"] = status;
    _data["requestId"] = requestId;
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    return _data;
  }
}

class To {
  String? email;
  String? notificationSubsId;

  To({this.email, this.notificationSubsId});

  To.fromJson(Map<String, dynamic> json) {
    email = json["email"];
    notificationSubsId = json["notificationSubsId"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["email"] = email;
    _data["notificationSubsId"] = notificationSubsId;
    return _data;
  }
}

class From {
  String? email;
  String? notificationSubsId;

  From({this.email, this.notificationSubsId});

  From.fromJson(Map<String, dynamic> json) {
    email = json["email"];
    notificationSubsId = json["notificationSubsId"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["email"] = email;
    _data["notificationSubsId"] = notificationSubsId;
    return _data;
  }
}