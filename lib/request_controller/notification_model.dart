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
  String? notificationTypeAr;
  String? message;
  String? messageAr;
  String? title;
  String? titleAr;
  String? metaData;
  List<From>? from;
  List<To>? to;
  String? notificationMessage;
  String? notificationMessageAr;
  String? status;
  String? requestId;
  String? attachment;
  DurationSettings? durationSettings;
  String? createdAt;
  String? updatedAt;
  int? v;

  Data({
    this.id,
    this.notificationType,
    this.notificationTypeAr,
    this.message,
    this.messageAr,
    this.title,
    this.titleAr,
    this.metaData,
    this.from,
    this.to,
    this.notificationMessage,
    this.notificationMessageAr,
    this.status,
    this.requestId,
    this.attachment,
    this.durationSettings,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    notificationType = json["notificationType"];
    notificationTypeAr = json["notificationTypeAr"];
    message = json["message"];
    messageAr = json["messageAr"];
    title = json["title"];
    titleAr = json["titleAr"];
    metaData = json["metaData"];
    if (json["from"] is List) {
      from = (json["from"] as List)
          .map((e) => e is Map<String, dynamic> ? From.fromJson(e) : From(email: e.toString()))
          .toList();
    }
    if (json["to"] is List) {
      to = (json["to"] as List)
          .map((e) => e is Map<String, dynamic> ? To.fromJson(e) : To(email: e.toString()))
          .toList();
    }

    notificationMessage = json["notificationMessage"];
    notificationMessageAr = json["notificationMessageAr"];
    status = json["status"];
    requestId = json["requestId"];
    attachment = json["attachment"];
    durationSettings = json["durationSettings"] == null ? null : DurationSettings.fromJson(json["durationSettings"]);
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["notificationType"] = notificationType;
    _data["notificationTypeAr"] = notificationTypeAr;
    _data["message"] = message;
    _data["title"] = title;
    _data["metaData"] = metaData;
    if (from != null) {
      _data["from"] = from?.map((e) => e.toJson()).toList();
    }
    if (to != null) {
      _data["to"] = to?.map((e) => e.toJson()).toList();
    }
    _data["notificationMessage"] = notificationMessage;
    _data["status"] = status;
    _data["requestId"] = requestId;
    _data["requestId"] = requestId;
    _data["attachment"] = attachment;
    if(durationSettings != null) {
      _data["durationSettings"] = durationSettings?.toJson();
    }
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    return _data;
  }
}

class DurationSettings {
  String? expiryDate;
  String? displaySetting;

  DurationSettings({this.expiryDate, this.displaySetting});

  DurationSettings.fromJson(Map<String, dynamic> json) {
    expiryDate = json["expiryDate"];
    displaySetting = json["displaySetting"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["expiryDate"] = expiryDate;
    _data["displaySetting"] = displaySetting;
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