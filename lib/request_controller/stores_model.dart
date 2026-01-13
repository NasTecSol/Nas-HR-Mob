
class StoresModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  List<Data>? data;

  StoresModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  StoresModel.fromJson(Map<String, dynamic> json) {
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
  String? storeName;
  String? storeLocation;
  String? address;
  double? lat;
  double? lng;
  String? city;
  String? country;
  String? storeType;
  String? ownerName;
  String? area;
  int? areaCode;
  String? storePic;
  List<dynamic>? attachments;
  List<ContactDetails>? contactDetails;
  String? createdBy;
  String? createdAt;
  String? updatedAt;
  int? v;

  Data({this.id, this.storeName, this.storeLocation, this.address, this.lat, this.lng, this.city, this.country, this.storeType, this.ownerName, this.area, this.areaCode, this.storePic, this.attachments, this.contactDetails, this.createdBy, this.createdAt, this.updatedAt, this.v});

  Data.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    storeName = json["storeName"];
    storeLocation = json["storeLocation"];
    address = json["address"];
    lat = json["lat"];
    lng = json["lng"];
    city = json["city"];
    country = json["country"];
    storeType = json["storeType"];
    ownerName = json["ownerName"];
    area = json["area"];
    areaCode = json["areaCode"];
    storePic = json["storePic"];
    attachments = json["attachments"] ?? [];
    contactDetails = json["contactDetails"] == null ? null : (json["contactDetails"] as List).map((e) => ContactDetails.fromJson(e)).toList();
    createdBy = json["createdBy"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["storeName"] = storeName;
    _data["storeLocation"] = storeLocation;
    _data["address"] = address;
    _data["lat"] = lat;
    _data["lng"] = lng;
    _data["city"] = city;
    _data["country"] = country;
    _data["storeType"] = storeType;
    _data["ownerName"] = ownerName;
    _data["area"] = area;
    _data["areaCode"] = areaCode;
    _data["storePic"] = storePic;
    if(attachments != null) {
      _data["attachments"] = attachments;
    }
    if(contactDetails != null) {
      _data["contactDetails"] = contactDetails?.map((e) => e.toJson()).toList();
    }
    _data["createdBy"] = createdBy;
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    return _data;
  }
}

class ContactDetails {
  String? contactName;
  String? contactNumber;
  String? designation;

  ContactDetails({this.contactName, this.contactNumber, this.designation});

  ContactDetails.fromJson(Map<String, dynamic> json) {
    contactName = json["contactName"];
    contactNumber = json["contactNumber"];
    designation = json["designation"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["contactName"] = contactName;
    _data["contactNumber"] = contactNumber;
    _data["designation"] = designation;
    return _data;
  }
}
