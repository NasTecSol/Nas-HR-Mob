class UiSettingsModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  Data? data;

  UiSettingsModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  UiSettingsModel.fromJson(Map<String, dynamic> json) {
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
  String? grade;
  String? role;
  List<UiModules>? uiModules;
  List<MobileModules>? mobileModules;

  Data({this.grade, this.role, this.uiModules, this.mobileModules});

  Data.fromJson(Map<String, dynamic> json) {
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
  List<dynamic>? subMenu;

  MobileModules({this.title, this.navigationUrl, this.name, this.icon, this.isTab, this.hidden, this.subMenu});

  MobileModules.fromJson(Map<String, dynamic> json) {
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