class AssetDetailsModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  List<Data>? data;

  AssetDetailsModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  factory AssetDetailsModel.fromJson(Map<String, dynamic> json) {
    return AssetDetailsModel(
      statusCode: json["statusCode"],
      statusMessage: json["statusMessage"],
      errorMessage: json["errorMessage"],
      data: json["data"] == null
          ? null
          : List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "statusMessage": statusMessage,
    "errorMessage": errorMessage,
    "data": data == null ? null : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}


class Data {
  String? id;
  String? templateType;
  ObjectDetails? objectDetails;
  int? randomId;
  int? v;

  Data({this.id, this.templateType, this.objectDetails, this.randomId, this.v});

  factory Data.fromJson(Map<String, dynamic> json) {
    ObjectDetails? objDet;
    if (json["objectDetails"] != null && json["objectDetails"] is Map<String, dynamic>) {
      objDet = ObjectDetails.fromJson(Map<String, dynamic>.from(json["objectDetails"]));
    } else {
      objDet = ObjectDetails.fromJson(json);
    }

    return Data(
      id: json["_id"]?.toString() ?? json["id"]?.toString(),
      templateType: json["templateType"]?.toString() ?? json["type"]?.toString(),
      objectDetails: objDet,
      randomId: json["randomId"] is int
          ? json["randomId"]
          : int.tryParse(json["randomId"]?.toString() ?? ''),
      v: json["__v"] is int
          ? json["__v"]
          : int.tryParse(json["__v"]?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "templateType": templateType,
    "objectDetails": objectDetails?.toJson(),
    "randomId": randomId,
    "__v": v,
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
    } else if (json["image"] != null) {
      imageString = json["image"].toString();
    }

    Map<String, dynamic>? params;
    if (json["parameters"] != null && json["parameters"] is Map) {
      params = Map<String, dynamic>.from(json["parameters"]);
    } else if (json["details"] != null && json["details"] is Map) {
      params = Map<String, dynamic>.from(json["details"]);
    }

    final objName = json["objectName"]?.toString() ??
        json["assetName"]?.toString() ??
        json["name"]?.toString() ??
        json["title"]?.toString();

    final childList = <ChildObject>[];
    if (json["child_Objs"] != null && json["child_Objs"] is List) {
      for (var item in json["child_Objs"]) {
        if (item is Map) {
          childList.add(ChildObject.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    } else if (json["childObjs"] != null && json["childObjs"] is List) {
      for (var item in json["childObjs"]) {
        if (item is Map) {
          childList.add(ChildObject.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return ObjectDetails(
      objectName: objName,
      objectIcon: json["objectIcon"]?.toString(),
      img: imageString,
      childObjs: childList,
      parameters: params,
      additionalInfo: Map<String, dynamic>.from(json)
        ..removeWhere((key, value) => ["objectName", "objectIcon", "child_Objs", "childObjs", "img", "image", "parameters", "details"].contains(key)),
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