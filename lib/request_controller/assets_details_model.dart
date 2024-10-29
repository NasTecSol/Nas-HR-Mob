class AssetDetailsModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  Data? data;

  AssetDetailsModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  AssetDetailsModel.fromJson(Map<String, dynamic> json) {
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
    if (data != null) {
      _data["data"] = data?.toJson();
    }
    return _data;
  }
}

class Data {
  String? id;
  String? templateType;
  ObjectDetails? objectDetails;
  int? randomId;
  int? v;

  Data({this.id, this.templateType, this.objectDetails, this.randomId, this.v});

  Data.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    templateType = json["templateType"];
    objectDetails = json["objectDetails"] == null ? null : ObjectDetails.fromJson(json["objectDetails"]);
    randomId = json["randomId"];
    v = json["__v"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["templateType"] = templateType;
    if (objectDetails != null) {
      _data["objectDetails"] = objectDetails?.toJson();
    }
    _data["randomId"] = randomId;
    _data["__v"] = v;
    return _data;
  }
}

class ObjectDetails {
  String? objectName;
  String? objectIcon;
  String? img; // Holds the base64 image string
  List<ChildObject>? childObjs; // List of child objects
  Map<String, dynamic>? parameters; // To hold parameters
  Map<String, dynamic>? additionalInfo; // Holds random keys and values

  ObjectDetails({
    this.objectName,
    this.objectIcon,
    this.img,
    this.childObjs,
    this.parameters,
    this.additionalInfo,
  });

  ObjectDetails.fromJson(Map<String, dynamic> json) {
    objectName = json["objectName"];
    objectIcon = json["objectIcon"];
    img = json["img"] != null ? json["img"].values.first : null; // Get the Base64 string

    // Correctly map child objects to ChildObject instances
    childObjs = json["child_Objs"] != null
        ? (json["child_Objs"] as List)
        .map((childJson) => ChildObject.fromJson(childJson)) // Proper instantiation
        .toList()
        : [];

    parameters = json["parameters"] != null ? Map<String, dynamic>.from(json["parameters"]) : null;

    // Extract random keys and store them in additionalInfo
    additionalInfo = Map<String, dynamic>.from(json)
      ..removeWhere((key, value) =>
          ["objectName", "objectIcon", "child_Objs", "img", "parameters"].contains(key));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["objectName"] = objectName;
    _data["objectIcon"] = objectIcon;
    _data["img"] = img;
    if (childObjs != null) {
      _data["child_Objs"] = childObjs!.map((child) => child.toJson()).toList();
    }
    if (parameters != null) {
      _data["parameters"] = parameters!;
    }

    // Add additionalInfo back to the main data
    if (additionalInfo != null) {
      _data.addAll(additionalInfo!);
    }

    return _data;
  }
}

class ChildObject {
  String? objectName;
  Map<String, dynamic>? parameters; // Holds the parameters dynamically
  Map<String, dynamic>? additionalInfo; // Holds additional information dynamically

  ChildObject({this.objectName, this.parameters, this.additionalInfo});

  ChildObject.fromJson(Map<String, dynamic> json) {
    objectName = json["objectName"];
    parameters = json["parameters"] != null
        ? Map<String, dynamic>.from(json["parameters"])
        : null;

    // Extract random keys and store them in additionalInfo
    additionalInfo = Map<String, dynamic>.from(json)
      ..removeWhere((key, value) =>
          ["objectName", "parameters"].contains(key));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["objectName"] = objectName;
    if (parameters != null) {
      _data["parameters"] = parameters!;
    }

    // Add additionalInfo back to the main data
    if (additionalInfo != null) {
      _data.addAll(additionalInfo!);
    }

    return _data;
  }
}
