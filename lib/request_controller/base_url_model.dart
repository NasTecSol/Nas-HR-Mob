class TenantIdModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  Data? data;

  TenantIdModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  TenantIdModel.fromJson(Map<String, dynamic> json) {
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
  int? tenantId;
  String? tenantName;
  String? domainName;
  String? tenantLogo;
  String? tenantDescription;

  Data({this.tenantId, this.tenantName, this.domainName, this.tenantLogo, this.tenantDescription});

  Data.fromJson(Map<String, dynamic> json) {
    tenantId = json["tenantId"];
    tenantName = json["tenantName"];
    domainName = json["domainName"];
    tenantLogo = json["tenantLogo"];
    tenantDescription = json["tenantDescription"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["tenantId"] = tenantId;
    _data["tenantName"] = tenantName;
    _data["domainName"] = domainName;
    _data["tenantLogo"] = tenantLogo;
    _data["tenantDescription"] = tenantDescription;
    return _data;
  }
}