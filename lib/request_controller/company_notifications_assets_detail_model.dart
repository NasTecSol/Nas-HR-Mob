class CompanyNotificationsAssetsDetailModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  CompanyNotificationAssetData? data;

  CompanyNotificationsAssetsDetailModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  factory CompanyNotificationsAssetsDetailModel.fromJson(Map<String, dynamic> json) {
    return CompanyNotificationsAssetsDetailModel(
      statusCode: json["statusCode"],
      statusMessage: json["statusMessage"],
      errorMessage: json["errorMessage"],
      data: json["data"] == null ? null : CompanyNotificationAssetData.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "statusMessage": statusMessage,
    "errorMessage": errorMessage,
    "data": data?.toJson(),
  };
}

class CompanyNotificationAssetData {
  String? id;
  String? templateType;
  ObjectDetails? objectDetails;
  int? randomId;
  int? v;
  OwnerInfo? ownerInfo;

  CompanyNotificationAssetData({
    this.id,
    this.templateType,
    this.objectDetails,
    this.randomId,
    this.v,
    this.ownerInfo,
  });

  factory CompanyNotificationAssetData.fromJson(Map<String, dynamic> json) => CompanyNotificationAssetData(
    id: json["_id"],
    templateType: json["templateType"],
    objectDetails: json["objectDetails"] == null ? null : ObjectDetails.fromJson(json["objectDetails"]),
    randomId: json["randomId"],
    v: json["__v"],
    ownerInfo: json["ownerInfo"] == null ? null : OwnerInfo.fromJson(json["ownerInfo"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "templateType": templateType,
    "objectDetails": objectDetails?.toJson(),
    "randomId": randomId,
    "__v": v,
    "ownerInfo": ownerInfo?.toJson(),
  };
}

class ObjectDetails {
  String? objectName;
  String? objectIcon;
  String? img; // base64 string or URL string
  List<ChildObject>? childObjs;
  Map<String, dynamic>? parameters;
  Map<String, dynamic>? additionalInfo;

  ObjectDetails({
    this.objectName,
    this.objectIcon,
    this.img,
    this.childObjs,
    this.parameters,
    this.additionalInfo,
  });

  factory ObjectDetails.fromJson(Map<String, dynamic> json) {
    // Fix img: check if it's a map (for base64) or a string (url)
    String? imageString;
    if (json["img"] != null) {
      if (json["img"] is Map) {
        imageString = (json["img"] as Map).values.first.toString();
      } else if (json["img"] is String) {
        imageString = json["img"];
      }
    }

    return ObjectDetails(
      objectName: json["objectName"],
      objectIcon: json["objectIcon"],
      img: imageString,
      childObjs: json["child_Objs"] != null
          ? List<ChildObject>.from(json["child_Objs"].map((x) => ChildObject.fromJson(x)))
          : [],
      parameters: json["parameters"] != null ? Map<String, dynamic>.from(json["parameters"]) : null,
      additionalInfo: Map<String, dynamic>.from(json)
        ..removeWhere((key, value) => ["objectName", "objectIcon", "child_Objs", "img", "parameters"].contains(key)),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["objectName"] = objectName;
    map["objectIcon"] = objectIcon;
    map["img"] = img;
    map["child_Objs"] = childObjs?.map((x) => x.toJson()).toList();
    map["parameters"] = parameters;
    if (additionalInfo != null) {
      map.addAll(additionalInfo!);
    }
    return map;
  }
}

class ChildObject {
  String? objectName;
  Map<String, dynamic>? parameters;
  Map<String, dynamic>? additionalInfo;

  ChildObject({this.objectName, this.parameters, this.additionalInfo});

  factory ChildObject.fromJson(Map<String, dynamic> json) {
    return ChildObject(
      objectName: json["objectName"],
      parameters: json["parameters"] != null ? Map<String, dynamic>.from(json["parameters"]) : null,
      additionalInfo: Map<String, dynamic>.from(json)
        ..removeWhere((key, value) => ["objectName", "parameters"].contains(key)),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map["objectName"] = objectName;
    map["parameters"] = parameters;
    if (additionalInfo != null) {
      map.addAll(additionalInfo!);
    }
    return map;
  }
}

class OwnerInfo {
  Map<String, dynamic>? additionalInfo;

  OwnerInfo({this.additionalInfo});

  factory OwnerInfo.fromJson(Map<String, dynamic> json) {
    return OwnerInfo(
      additionalInfo: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (additionalInfo != null) {
      map.addAll(additionalInfo!);
    }
    return map;
  }
}