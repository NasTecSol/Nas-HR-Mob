class CompaniesDataModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  Data? data;

  CompaniesDataModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  CompaniesDataModel.fromJson(Map<String, dynamic> json) {
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
  String? organizationName;
  String? organizationTitle;
  String? licenseId;
  String? country;
  String? address;
  String? settings;
  List<HierarchyGroups>? hierarchyGroups;
  List<UiSettings>? uiSettings;
  String? createdBy;
  String? createdAt;
  String? updatedAt;
  int? v;
  List<Companies>? companies;
  String? empCode;

  Data({this.id, this.organizationName, this.organizationTitle, this.licenseId, this.country, this.address, this.settings, this.hierarchyGroups, this.uiSettings, this.createdBy, this.createdAt, this.updatedAt, this.v, this.companies, this.empCode});

  Data.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    organizationName = json["organizationName"];
    organizationTitle = json["organizationTitle"];
    licenseId = json["licenseId"];
    country = json["country"];
    address = json["address"];
    settings = json["settings"];
    hierarchyGroups = json["hierarchyGroups"] == null ? null : (json["hierarchyGroups"] as List).map((e) => HierarchyGroups.fromJson(e)).toList();
    uiSettings = json["uiSettings"] == null ? null : (json["uiSettings"] as List).map((e) => UiSettings.fromJson(e)).toList();
    createdBy = json["createdBy"];
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
    companies = json["companies"] == null ? null : (json["companies"] as List).map((e) => Companies.fromJson(e)).toList();
    empCode = json["empCode"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["organizationName"] = organizationName;
    _data["organizationTitle"] = organizationTitle;
    _data["licenseId"] = licenseId;
    _data["country"] = country;
    _data["address"] = address;
    _data["settings"] = settings;
    if(hierarchyGroups != null) {
      _data["hierarchyGroups"] = hierarchyGroups?.map((e) => e.toJson()).toList();
    }
    if(uiSettings != null) {
      _data["uiSettings"] = uiSettings?.map((e) => e.toJson()).toList();
    }
    _data["createdBy"] = createdBy;
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    if(companies != null) {
      _data["companies"] = companies?.map((e) => e.toJson()).toList();
    }
    _data["empCode"] = empCode;
    return _data;
  }
}

class Companies {
  String? companyId;
  String? companyName;
  String? companyLogo;

  Companies({this.companyId, this.companyName, this.companyLogo});

  Companies.fromJson(Map<String, dynamic> json) {
    companyId = json["companyId"];
    companyName = json["companyName"];
    companyLogo = json["companyLogo"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["companyId"] = companyId;
    _data["companyName"] = companyName;
    _data["companyLogo"] = companyLogo;
    return _data;
  }
}

class UiSettings {
  String? grade;
  String? role;
  List<UiModules>? uiModules;
  List<MobileModules>? mobileModules;

  UiSettings({this.grade, this.role, this.uiModules, this.mobileModules});

  UiSettings.fromJson(Map<String, dynamic> json) {
    grade = json["grade"];
    role = json["role"];
    uiModules = json["uiModules"] == null ? null : (json["uiModules"] as List).map((e) => UiModules.fromJson(e)).toList();
    mobileModules = json["mobileModules"] == null ? null : (json["mobileModules"] as List).map((e) => MobileModules.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["grade"] = grade;
    _data["role"] = role;
    if(uiModules != null) {
      _data["uiModules"] = uiModules?.map((e) => e.toJson()).toList();
    }
    if(mobileModules != null) {
      _data["mobileModules"] = mobileModules?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class MobileModules {
  String? title;
  String? navigationUrl;
  String? name;
  String? icon;
  bool? isTab;
  bool? hidden;
  List<SubMenu>? subMenu;

  MobileModules({this.title, this.navigationUrl, this.name, this.icon, this.isTab, this.hidden, this.subMenu});

  MobileModules.fromJson(Map<String, dynamic> json) {
    title = json["title"];
    navigationUrl = json["navigationURL"];
    name = json["name"];
    icon = json["icon"];
    isTab = json["isTab"];
    hidden = json["hidden"];
    subMenu = json["subMenu"] == null ? null : (json["subMenu"] as List).map((e) => SubMenu.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["title"] = title;
    _data["navigationURL"] = navigationUrl;
    _data["name"] = name;
    _data["icon"] = icon;
    _data["isTab"] = isTab;
    _data["hidden"] = hidden;
    if(subMenu != null) {
      _data["subMenu"] = subMenu?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class SubMenu {
  String? title;
  String? navigationUrl;
  String? name;
  String? icon;
  bool? hidden;
  List<dynamic>? subMenu;

  SubMenu({this.title, this.navigationUrl, this.name, this.icon, this.hidden, this.subMenu});

  SubMenu.fromJson(Map<String, dynamic> json) {
    title = json["title"];
    navigationUrl = json["navigationURL"];
    name = json["name"];
    icon = json["icon"];
    hidden = json["hidden"];
    subMenu = json["subMenu"] ?? [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["title"] = title;
    _data["navigationURL"] = navigationUrl;
    _data["name"] = name;
    _data["icon"] = icon;
    _data["hidden"] = hidden;
    if(subMenu != null) {
      _data["subMenu"] = subMenu;
    }
    return _data;
  }
}

class UiModules {
  String? title;
  String? navigationUrl;
  String? name;
  String? icon;
  bool? isTab;
  bool? hidden;
  List<dynamic>? subMenu;

  UiModules({this.title, this.navigationUrl, this.name, this.icon, this.isTab, this.hidden, this.subMenu});

  UiModules.fromJson(Map<String, dynamic> json) {
    title = json["title"];
    navigationUrl = json["navigationURL"];
    name = json["name"];
    icon = json["icon"];
    isTab = json["isTab"];
    hidden = json["hidden"];
    subMenu = json["subMenu"] ?? [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["title"] = title;
    _data["navigationURL"] = navigationUrl;
    _data["name"] = name;
    _data["icon"] = icon;
    _data["isTab"] = isTab;
    _data["hidden"] = hidden;
    if(subMenu != null) {
      _data["subMenu"] = subMenu;
    }
    return _data;
  }
}

class HierarchyGroups {
  String? grade;
  List<String>? roles;

  HierarchyGroups({this.grade, this.roles});

  HierarchyGroups.fromJson(Map<String, dynamic> json) {
    grade = json["grade"];
    roles = json["roles"] == null ? null : List<String>.from(json["roles"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["grade"] = grade;
    if(roles != null) {
      _data["roles"] = roles;
    }
    return _data;
  }
}