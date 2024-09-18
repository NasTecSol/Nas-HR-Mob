
class CompanyData {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  Data? data;

  CompanyData({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  CompanyData.fromJson(Map<String, dynamic> json) {
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
  String? id;
  String? name;
  String? title;
  String? city;
  String? country;
  String? address;
  String? shortCode;
  String? licenseId;
  String? establishmentNo;
  String? commericalReg;
  License? license;
  String? phoneNumber;
  String? email;
  int? extension;
  List<Rules>? rules;
  List<Policies>? policies;
  List<String>? assets;
  List<String>? documents;
  String? createdBy;
  String? organizationId;
  String? createdAt;
  String? updatedAt;
  int? v;
  List<ApprovalGroupData>? approvalGroupData;
  List<Request>? request;

  Data({this.id, this.name, this.title, this.city, this.country, this.address, this.shortCode, this.licenseId, this.establishmentNo, this.commericalReg, this.license, this.phoneNumber, this.email, this.extension, this.rules, this.policies, this.assets, this.documents, this.createdBy, this.organizationId, this.createdAt, this.updatedAt, this.v, this.approvalGroupData, this.request});

  Data.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    name = json["name"];
    title = json["title"];
    city = json["city"];
    country = json["country"];
    address = json["address"];
    shortCode = json["shortCode"];
    licenseId = json["licenseId"];
    establishmentNo = json["establishmentNo"];
    commericalReg = json["commericalReg"];
    license = json["license"] == null ? null : License.fromJson(json["license"]);
    phoneNumber = json["phoneNumber"];
    email = json["email"];
    extension = json["extension"];
    rules = json["rules"] == null ? null : (json["rules"] as List).map((e) => Rules.fromJson(e)).toList();
    policies = json["policies"] == null ? null : (json["policies"] as List).map((e) => Policies.fromJson(e)).toList();
    assets = json["assets"] == null ? null : List<String>.from(json["assets"]);
    documents = json["documents"] == null ? null : List<String>.from(json["documents"]);
    createdBy = json["createdBy"];
    organizationId = json["organizationId"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
    approvalGroupData = json["approvalGroupData"] == null ? null : (json["approvalGroupData"] as List).map((e) => ApprovalGroupData.fromJson(e)).toList();
    request = json["request"] == null ? null : (json["request"] as List).map((e) => Request.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["name"] = name;
    _data["title"] = title;
    _data["city"] = city;
    _data["country"] = country;
    _data["address"] = address;
    _data["shortCode"] = shortCode;
    _data["licenseId"] = licenseId;
    _data["establishmentNo"] = establishmentNo;
    _data["commericalReg"] = commericalReg;
    if(license != null) {
      _data["license"] = license?.toJson();
    }
    _data["phoneNumber"] = phoneNumber;
    _data["email"] = email;
    _data["extension"] = extension;
    if(rules != null) {
      _data["rules"] = rules?.map((e) => e.toJson()).toList();
    }
    if(policies != null) {
      _data["policies"] = policies?.map((e) => e.toJson()).toList();
    }
    if(assets != null) {
      _data["assets"] = assets;
    }
    if(documents != null) {
      _data["documents"] = documents;
    }
    _data["createdBy"] = createdBy;
    _data["organizationId"] = organizationId;
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    if(approvalGroupData != null) {
      _data["approvalGroupData"] = approvalGroupData?.map((e) => e.toJson()).toList();
    }
    if(request != null) {
      _data["request"] = request?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Request {
  int? groupId;
  String? requestType;
  String? requestName;
  bool? docRequired;
  List<SubTypes>? subTypes;

  Request({this.groupId, this.requestType, this.requestName, this.docRequired, this.subTypes});

  Request.fromJson(Map<String, dynamic> json) {
    groupId = json["groupId"];
    requestType = json["requestType"];
    requestName = json["requestName"];
    docRequired = json["docRequired"];
    subTypes = json["subTypes"] == null ? null : (json["subTypes"] as List).map((e) => SubTypes.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["groupId"] = groupId;
    _data["requestType"] = requestType;
    _data["requestName"] = requestName;
    _data["docRequired"] = docRequired;
    if(subTypes != null) {
      _data["subTypes"] = subTypes?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class SubTypes {
  String? requestType;
  String? requestName;
  bool? docRequired;

  SubTypes({this.requestType, this.requestName, this.docRequired});

  SubTypes.fromJson(Map<String, dynamic> json) {
    requestType = json["requestType"];
    requestName = json["requestName"];
    docRequired = json["docRequired"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["requestType"] = requestType;
    _data["requestName"] = requestName;
    _data["docRequired"] = docRequired;
    return _data;
  }
}

class ApprovalGroupData {
  int? groupId;
  List<GroupData>? groupData;

  ApprovalGroupData({this.groupId, this.groupData});

  ApprovalGroupData.fromJson(Map<String, dynamic> json) {
    groupId = json["groupId"];
    groupData = json["groupData"] == null ? null : (json["groupData"] as List).map((e) => GroupData.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["groupId"] = groupId;
    if(groupData != null) {
      _data["groupData"] = groupData?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class GroupData {
  String? employeeId;
  String? name;
  String? designation;
  String? grade;
  String? departmentId;
  bool? isOptional;

  GroupData({this.employeeId, this.name, this.designation, this.grade, this.departmentId, this.isOptional});

  GroupData.fromJson(Map<String, dynamic> json) {
    employeeId = json["employeeId"];
    name = json["name"];
    designation = json["designation"];
    grade = json["grade"];
    departmentId = json["departmentId"];
    isOptional = json["isOptional"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["employeeId"] = employeeId;
    _data["name"] = name;
    _data["designation"] = designation;
    _data["grade"] = grade;
    _data["departmentId"] = departmentId;
    _data["isOptional"] = isOptional;
    return _data;
  }
}

class Policies {
  String? policyId;
  String? policyName;
  String? policyType;

  Policies({this.policyId, this.policyName, this.policyType});

  Policies.fromJson(Map<String, dynamic> json) {
    policyId = json["policyId"];
    policyName = json["policyName"];
    policyType = json["policyType"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["policyId"] = policyId;
    _data["policyName"] = policyName;
    _data["policyType"] = policyType;
    return _data;
  }
}

class Rules {
  String? rules;

  Rules({this.rules});

  Rules.fromJson(Map<String, dynamic> json) {
    rules = json["rules"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["rules"] = rules;
    return _data;
  }
}

class License {
  String? licenseDetails;

  License({this.licenseDetails});

  License.fromJson(Map<String, dynamic> json) {
    licenseDetails = json["licenseDetails"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["licenseDetails"] = licenseDetails;
    return _data;
  }
}