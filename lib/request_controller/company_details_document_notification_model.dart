class CompanyDetailsDocumentNotificationModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  List<AssetTemplate>? data;

  CompanyDetailsDocumentNotificationModel({
    this.statusCode,
    this.statusMessage,
    this.errorMessage,
    this.data,
  });

  CompanyDetailsDocumentNotificationModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    statusMessage = json['statusMessage'];
    errorMessage = json['errorMessage'];
    data = json['data'] == null
        ? []
        : (json['data'] as List)
        .map((e) => AssetTemplate.fromJson(e))
        .toList();
  }
}


class AssetTemplate {
  String? id;
  String? templateType;
  ObjectDetails? objectDetails;
  int? randomId;
  OwnerInfo? ownerInfo;

  AssetTemplate({
    this.id,
    this.templateType,
    this.objectDetails,
    this.randomId,
    this.ownerInfo,
  });

  AssetTemplate.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    templateType = json['templateType'];
    randomId = json['randomId'];
    objectDetails = json['objectDetails'] == null
        ? null
        : ObjectDetails.fromJson(json['objectDetails']);
    ownerInfo = json['ownerInfo'] == null
        ? null
        : OwnerInfo.fromJson(json['ownerInfo']);
  }
}

class ObjectDetails {
  String? objectName;
  String? objectIcon;
  Map<String, dynamic>? parameters;
  List<ChildObject>? childObjects;
  DriverInfo? driverInfo;

  ObjectDetails.fromJson(Map<String, dynamic> json) {
    objectName = json['objectName'];
    objectIcon = json['objectIcon'];
    parameters = json['parameters'];
    childObjects = json['child_Objs'] == null
        ? []
        : (json['child_Objs'] as List)
        .map((e) => ChildObject.fromJson(e))
        .toList();
    driverInfo = json['driverInfo'] == null
        ? null
        : DriverInfo.fromJson(json['driverInfo']);
  }
}


class ChildObject {
  String? objectName;
  Map<String, dynamic>? parameters;

  ChildObject.fromJson(Map<String, dynamic> json) {
    objectName = json['objectName'];
    parameters = json['parameters'];
  }
}

class DriverInfo {
  DateInfo? driverCardInfo;
  DateInfo? actualUserAuthorization;

  DriverInfo.fromJson(Map<String, dynamic> json) {
    driverCardInfo = json['driverCardInfo'] == null
        ? null
        : DateInfo.fromJson(json['driverCardInfo']);
    actualUserAuthorization = json['actualUserAuthorization'] == null
        ? null
        : DateInfo.fromJson(json['actualUserAuthorization']);
  }
}

class OwnerInfo {
  DateInfo? driverLicenseInfo;
  DateInfo? driverCardInfo;
  DateInfo? actualUserAuthorization;

  OwnerInfo.fromJson(Map<String, dynamic> json) {
    driverLicenseInfo = json['driverLicenseInfo'] == null
        ? null
        : DateInfo.fromJson(json['driverLicenseInfo']);
    driverCardInfo = json['driverCardInfo'] == null
        ? null
        : DateInfo.fromJson(json['driverCardInfo']);
    actualUserAuthorization = json['actualUserAuthorization'] == null
        ? null
        : DateInfo.fromJson(json['actualUserAuthorization']);
  }
}

class DateInfo {
  String? driverId;
  String? startDate;
  String? endDate;

  DateInfo.fromJson(Map<String, dynamic> json) {
    driverId = json['driverId'];
    startDate = json['startDate'];
    endDate = json['endDate'];
  }
}
