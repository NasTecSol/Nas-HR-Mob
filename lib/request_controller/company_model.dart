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
  String? logo;
  License? license;
  String? phoneNumber;
  String? email;
  int? extension;
  List<Rules>? rules;
  List<Policies>? policies;
  List<dynamic>? assets;
  List<dynamic>? documents;
  List<Request>? request;
  List<ApprovalGroupData>? approvalGroupData;
  String? createdBy;
  String? organizationId;
  NotificationSettings? notificationSettings;
  PayrollSettings? payrollSettings;
  ExpenseSettings? expenseSettings;
  String? createdAt;
  String? updatedAt;
  int? v;

  Data({this.id, this.name, this.title, this.city, this.country, this.address, this.shortCode, this.licenseId, this.establishmentNo, this.commericalReg, this.logo, this.license, this.phoneNumber, this.email, this.extension, this.rules, this.policies, this.assets, this.documents, this.request, this.approvalGroupData, this.createdBy, this.organizationId, this.notificationSettings, this.payrollSettings, this.expenseSettings, this.createdAt, this.updatedAt, this.v});

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
    logo = json["logo"];
    license = json["license"] == null ? null : License.fromJson(json["license"]);
    phoneNumber = json["phoneNumber"];
    email = json["email"];
    extension = json["extension"];
    rules = json["rules"] == null ? null : (json["rules"] as List).map((e) => Rules.fromJson(e)).toList();
    policies = json["policies"] == null ? null : (json["policies"] as List).map((e) => Policies.fromJson(e)).toList();
    assets = json["assets"] ?? [];
    documents = json["documents"] ?? [];
    request = json["request"] == null ? null : (json["request"] as List).map((e) => Request.fromJson(e)).toList();
    approvalGroupData = json["approvalGroupData"] == null ? null : (json["approvalGroupData"] as List).map((e) => ApprovalGroupData.fromJson(e)).toList();
    createdBy = json["createdBy"];
    organizationId = json["organizationId"];
    notificationSettings = json["notificationSettings"] == null ? null : NotificationSettings.fromJson(json["notificationSettings"]);
    payrollSettings = json["payrollSettings"] == null ? null : PayrollSettings.fromJson(json["payrollSettings"]);
    expenseSettings = json["expenseSettings"] == null ? null : ExpenseSettings.fromJson(json["expenseSettings"]);
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
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
    _data["logo"] = logo;
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
    if(request != null) {
      _data["request"] = request?.map((e) => e.toJson()).toList();
    }
    if(approvalGroupData != null) {
      _data["approvalGroupData"] = approvalGroupData?.map((e) => e.toJson()).toList();
    }
    _data["createdBy"] = createdBy;
    _data["organizationId"] = organizationId;
    if(notificationSettings != null) {
      _data["notificationSettings"] = notificationSettings?.toJson();
    }
    if(payrollSettings != null) {
      _data["payrollSettings"] = payrollSettings?.toJson();
    }
    if(expenseSettings != null) {
      _data["expenseSettings"] = expenseSettings?.toJson();
    }
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    return _data;
  }
}

class ExpenseSettings {
  List<ExpenseCategories>? expenseCategories;
  List<ApprovalThresholds>? approvalThresholds;
  List<AdvanceRequestLimits>? advanceRequestLimits;
  List<AccountType>? accountType;

  ExpenseSettings({this.expenseCategories, this.approvalThresholds, this.advanceRequestLimits, this.accountType});

  ExpenseSettings.fromJson(Map<String, dynamic> json) {
    expenseCategories = json["expenseCategories"] == null ? null : (json["expenseCategories"] as List).map((e) => ExpenseCategories.fromJson(e)).toList();
    approvalThresholds = json["approvalThresholds"] == null ? null : (json["approvalThresholds"] as List).map((e) => ApprovalThresholds.fromJson(e)).toList();
    advanceRequestLimits = json["advanceRequestLimits"] == null ? null : (json["advanceRequestLimits"] as List).map((e) => AdvanceRequestLimits.fromJson(e)).toList();
    accountType = json["accountType"] == null ? null : (json["accountType"] as List).map((e) => AccountType.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if(expenseCategories != null) {
      _data["expenseCategories"] = expenseCategories?.map((e) => e.toJson()).toList();
    }
    if(approvalThresholds != null) {
      _data["approvalThresholds"] = approvalThresholds?.map((e) => e.toJson()).toList();
    }
    if(advanceRequestLimits != null) {
      _data["advanceRequestLimits"] = advanceRequestLimits?.map((e) => e.toJson()).toList();
    }
    if(accountType != null) {
      _data["accountType"] = accountType?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class AccountType {
  String? accountType;
  String? name;
  int? limit;
  bool? isDefault;
  int? creditLimit;
  int? expenseLimit;

  AccountType({this.accountType, this.name, this.limit, this.isDefault, this.creditLimit, this.expenseLimit});

  AccountType.fromJson(Map<String, dynamic> json) {
    accountType = json["accountType"];
    name = json["name"];
    limit = json["limit"];
    isDefault = json["isDefault"];
    creditLimit = json["creditLimit"];
    expenseLimit = json["expenseLimit"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["accountType"] = accountType;
    _data["name"] = name;
    _data["limit"] = limit;
    _data["isDefault"] = isDefault;
    _data["creditLimit"] = creditLimit;
    _data["expenseLimit"] = expenseLimit;
    return _data;
  }
}

class AdvanceRequestLimits {
  int? maxAmount;
  int? maxOutstandingRequests;

  AdvanceRequestLimits({this.maxAmount, this.maxOutstandingRequests});

  AdvanceRequestLimits.fromJson(Map<String, dynamic> json) {
    maxAmount = json["maxAmount"];
    maxOutstandingRequests = json["maxOutstandingRequests"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["maxAmount"] = maxAmount;
    _data["maxOutstandingRequests"] = maxOutstandingRequests;
    return _data;
  }
}

class ApprovalThresholds {
  int? amount;
  int? approvalGroupId;

  ApprovalThresholds({this.amount, this.approvalGroupId});

  ApprovalThresholds.fromJson(Map<String, dynamic> json) {
    amount = json["amount"];
    approvalGroupId = json["approvalGroupId"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["amount"] = amount;
    _data["approvalGroupId"] = approvalGroupId;
    return _data;
  }
}

class ExpenseCategories {
  String? name;
  String? description;
  bool? active;

  ExpenseCategories({this.name, this.description, this.active});

  ExpenseCategories.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    description = json["description"];
    active = json["active"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["name"] = name;
    _data["description"] = description;
    _data["active"] = active;
    return _data;
  }
}

class PayrollSettings {
  int? salaryDate;
  bool? editPayrollDraft;

  PayrollSettings({this.salaryDate, this.editPayrollDraft});

  PayrollSettings.fromJson(Map<String, dynamic> json) {
    salaryDate = json["salaryDate"];
    editPayrollDraft = json["editPayrollDraft"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["salaryDate"] = salaryDate;
    _data["editPayrollDraft"] = editPayrollDraft;
    return _data;
  }
}

class NotificationSettings {
  PushNotification? pushNotification;
  Emailsettings? emailsettings;
  NotificationTypes? notificationTypes;

  NotificationSettings({this.pushNotification, this.emailsettings, this.notificationTypes});

  NotificationSettings.fromJson(Map<String, dynamic> json) {
    pushNotification = json["pushNotification"] == null ? null : PushNotification.fromJson(json["pushNotification"]);
    emailsettings = json["emailsettings"] == null ? null : Emailsettings.fromJson(json["emailsettings"]);
    notificationTypes = json["notificationTypes"] == null ? null : NotificationTypes.fromJson(json["notificationTypes"]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if(pushNotification != null) {
      _data["pushNotification"] = pushNotification?.toJson();
    }
    if(emailsettings != null) {
      _data["emailsettings"] = emailsettings?.toJson();
    }
    if(notificationTypes != null) {
      _data["notificationTypes"] = notificationTypes?.toJson();
    }
    return _data;
  }
}

class NotificationTypes {
  bool? promotion;
  bool? alert;

  NotificationTypes({this.promotion, this.alert});

  NotificationTypes.fromJson(Map<String, dynamic> json) {
    promotion = json["promotion"];
    alert = json["alert"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["promotion"] = promotion;
    _data["alert"] = alert;
    return _data;
  }
}

class Emailsettings {
  bool? enabled;
  String? expiry;

  Emailsettings({this.enabled, this.expiry});

  Emailsettings.fromJson(Map<String, dynamic> json) {
    enabled = json["enabled"];
    expiry = json["expiry"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["enabled"] = enabled;
    _data["expiry"] = expiry;
    return _data;
  }
}

class PushNotification {
  bool? enabled;
  String? expiry;

  PushNotification({this.enabled, this.expiry});

  PushNotification.fromJson(Map<String, dynamic> json) {
    enabled = json["enabled"];
    expiry = json["expiry"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["enabled"] = enabled;
    _data["expiry"] = expiry;
    return _data;
  }
}

class ApprovalGroupData {
  int? groupId;
  String? groupName;
  List<GroupData>? groupData;

  ApprovalGroupData({this.groupId, this.groupName, this.groupData});

  ApprovalGroupData.fromJson(Map<String, dynamic> json) {
    groupId = json["groupId"];
    groupName = json["groupName"];
    groupData = json["groupData"] == null ? null : (json["groupData"] as List).map((e) => GroupData.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["groupId"] = groupId;
    _data["groupName"] = groupName;
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
  bool? isRequired;

  GroupData({this.employeeId, this.name, this.designation, this.grade, this.departmentId, this.isRequired});

  GroupData.fromJson(Map<String, dynamic> json) {
    employeeId = json["employeeId"];
    name = json["name"];
    designation = json["designation"];
    grade = json["grade"];
    departmentId = json["departmentId"];
    isRequired = json["isRequired"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["employeeId"] = employeeId;
    _data["name"] = name;
    _data["designation"] = designation;
    _data["grade"] = grade;
    _data["departmentId"] = departmentId;
    _data["isRequired"] = isRequired;
    return _data;
  }
}

class Request {
  int? groupId;
  String? requestType;
  String? requestName;
  bool? docRequired;
  List<SubTypes>? subTypes;
  String? groupName;

  Request({this.groupId, this.requestType, this.requestName, this.docRequired, this.subTypes, this.groupName});

  Request.fromJson(Map<String, dynamic> json) {
    groupId = json["groupId"];
    requestType = json["requestType"];
    requestName = json["requestName"];
    docRequired = json["docRequired"];
    subTypes = json["subTypes"] == null ? null : (json["subTypes"] as List).map((e) => SubTypes.fromJson(e)).toList();
    groupName = json["groupName"];
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
    _data["groupName"] = groupName;
    return _data;
  }
}

class SubTypes {
  String? requestType;
  String? requestName;
  dynamic docRequired;

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