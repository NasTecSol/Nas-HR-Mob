class RoleAndAccessModel {
  int? statusCode;
  String? statusMessage;
  String? errorMessage;
  Data? data;

  RoleAndAccessModel({
    this.statusCode,
    this.statusMessage,
    this.errorMessage,
    this.data,
  });

  RoleAndAccessModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    statusMessage = json['statusMessage'];
    errorMessage = json['errorMessage'];

    final rawData = json['data'];
    if (rawData != null) {
      if (rawData is List && rawData.isNotEmpty) {
        // ✅ if backend returns a list
        data = Data.fromJson(Map<String, dynamic>.from(rawData.first));
      } else if (rawData is Map<String, dynamic>) {
        // ✅ if backend returns an object
        data = Data.fromJson(rawData);
      }
    }
  }
}

class Data {
  String? id;
  String? type;
  UiSettings? uiSettings;

  Data({this.id, this.type, this.uiSettings});

  Data.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    type = json["type"];

    final uiSettingsData = json["uiSettings"];
    if (uiSettingsData != null) {
      if (uiSettingsData is Map<String, dynamic>) {
        // ✅ normal case
        uiSettings = UiSettings.fromJson(uiSettingsData);
      } else if (uiSettingsData is List && uiSettingsData.isNotEmpty) {
        // ✅ handle array edge case
        uiSettings = UiSettings.fromJson(Map<String, dynamic>.from(uiSettingsData.first));
      } else {
        uiSettings = null;
      }
    } else {
      uiSettings = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["_id"] = id;
    data["type"] = type;
    if (uiSettings != null) {
      data["uiSettings"] = uiSettings!.toJson();
    }
    return data;
  }
}


class UiSettings {
  String? grade;
  String? role;
  List<UiModule>? uiModules;

  UiSettings({this.grade, this.role, this.uiModules});

  UiSettings.fromJson(Map<String, dynamic> json) {
    grade = json['grade'];
    role = json['role'];
    if (json['uiModules'] != null) {
      uiModules = (json['uiModules'] as List)
          .map((e) => UiModule.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      uiModules = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['grade'] = grade;
    data['role'] = role;
    if (uiModules != null) {
      data['uiModules'] = uiModules!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class UiModule {
  String? title;
  String? navigationURL;
  String? name;
  String? type;
  bool? hidden;
  bool? nasMudeer;
  bool? onSiteCheckIn;
  bool? biometricCheckIn;
  AccessLevel? accessLevel;
  AccessType? accessType;
  List<SubMenu>? subMenu;

  UiModule({
    this.title,
    this.navigationURL,
    this.name,
    this.type,
    this.hidden,
    this.nasMudeer,
    this.accessLevel,
    this.accessType,
    this.subMenu,
  });

  UiModule.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    navigationURL = json['navigationURL'];
    name = json['name'];
    type = json['type'];
    hidden = json['hidden'];
    nasMudeer = json['nasMudeer'];
    onSiteCheckIn = json['onSiteCheckIn'];
    biometricCheckIn = json['biometricCheckIn'];
    accessLevel = json['accessLevel'] != null
        ? AccessLevel.fromJson(json['accessLevel'])
        : null;
    accessType = json['accessType'] != null
        ? AccessType.fromJson(json['accessType'])
        : null;
    if (json['subMenu'] != null) {
      subMenu = (json['subMenu'] as List)
          .map((e) => SubMenu.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      subMenu = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['title'] = title;
    data['navigationURL'] = navigationURL;
    data['name'] = name;
    data['type'] = type;
    data['hidden'] = hidden;
    data['nasMudeer'] = nasMudeer;
    data['onSiteCheckIn'] = onSiteCheckIn;
    data['biometricCheckIn'] = biometricCheckIn;
    if (accessLevel != null) {
      data['accessLevel'] = accessLevel!.toJson();
    }
    if (accessType != null) {
      data['accessType'] = accessType!.toJson();
    }
    if (subMenu != null) {
      data['subMenu'] = subMenu!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class AccessLevel {
  List<Company>? companies;
  bool? team;

  AccessLevel({this.companies, this.team});

  AccessLevel.fromJson(Map<String, dynamic> json) {
    if (json['companies'] != null) {
      companies = (json['companies'] as List)
          .map((e) => Company.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    team = json['team'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (companies != null) {
      data['companies'] = companies!.map((e) => e.toJson()).toList();
    }
    data['team'] = team;
    return data;
  }
}

class Company {
  String? companyId;
  String? companyName;
  List<Branch>? branches;
  List<dynamic>? team;

  Company({this.companyId, this.companyName, this.branches, this.team});

  Company.fromJson(Map<String, dynamic> json) {
    companyId = json['companyId'];
    companyName = json['companyName'];
    if (json['branches'] != null) {
      branches = (json['branches'] as List)
          .map((e) => Branch.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    team = json['team'] ?? [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['companyId'] = companyId;
    data['companyName'] = companyName;
    if (branches != null) {
      data['branches'] = branches!.map((e) => e.toJson()).toList();
    }
    data['team'] = team;
    return data;
  }
}

class Branch {
  String? branchId;
  String? branchName;

  Branch({this.branchId, this.branchName});

  Branch.fromJson(Map<String, dynamic> json) {
    branchId = json['branchId'];
    branchName = json['branchName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['branchId'] = branchId;
    data['branchName'] = branchName;
    return data;
  }
}

class AccessType {
  bool? read;
  bool? write;
  bool? add;

  AccessType({this.read, this.write, this.add});

  AccessType.fromJson(Map<String, dynamic> json) {
    read = json['read'];
    write = json['write'];
    add = json['add'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['read'] = read;
    data['write'] = write;
    data['add'] = add;
    return data;
  }
}


///Sub meunu
class SubMenu {
  String? title;
  String? navigationUrl;
  String? name;
  String? type;
  AccessLevel? accessLevel;
  AccessType? accessType;
  bool? hidden;
  bool? nasMudeer;
  List<dynamic>? subMenu; // Changed from List<SubMenu> to List<UiModules>
  bool? showSocketNotifications; // Added for Dashboard special case

  SubMenu({
    this.title,
    this.navigationUrl,
    this.name,
    this.type,
    this.accessLevel,
    this.accessType,
    this.hidden,
    this.nasMudeer,
    this.subMenu,
    this.showSocketNotifications
  });

  SubMenu.fromJson(Map<String, dynamic> json) {
    title = json["title"];
    navigationUrl = json["navigationURL"];
    name = json["name"];
    type = json["type"];
    accessLevel = json["accessLevel"] == null ? null : AccessLevel.fromJson(json["accessLevel"]);
    accessType = json["accessType"] == null ? null : AccessType.fromJson(json["accessType"]);
    hidden = json["hidden"];
    nasMudeer = json["nasMudeer"];
    showSocketNotifications = json["showSocketNotifications"];

    if (json["subMenu"] != null) {
      subMenu = (json["subMenu"] as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["title"] = title;
    data["navigationURL"] = navigationUrl;
    data["name"] = name;
    data["type"] = type;
    if(accessLevel != null) {
      data["accessLevel"] = accessLevel?.toJson();
    }
    if(accessType != null) {
      data["accessType"] = accessType?.toJson();
    }
    data["hidden"] = hidden;
    data["nasMudeer"] = nasMudeer;
    data["showSocketNotifications"] = showSocketNotifications;
    if(subMenu != null) {
      data["subMenu"] = subMenu?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}