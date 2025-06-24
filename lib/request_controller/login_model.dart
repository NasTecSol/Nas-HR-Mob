//Login Model
class LoginModel {
  final int? statusCode;
  final String? statusMessage;
  final String? errorMessage;
  final String? data;

  LoginModel({this.statusCode, this.statusMessage, this.data, this.errorMessage});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      statusCode: json['statusCode'],
      statusMessage: json['statusMessage'],
      data: json['data'] != null ? json['data']['token'] : null, // Convert data to string if it's not null
      errorMessage: json['errorMessage'],
    );
  }

  toList() {}
}

//Token Model
class JWTData {
  String? employeeId;
  String? companyId;
  String? tenantId;
  String? branchId;
  String? departmentId;
  String? organizationId;
  String? empId;
  String? userName;
  String? role;
  String? grade;
  int? iat;
  int? exp;

  JWTData({this.employeeId, this.companyId, this.tenantId, this.branchId, this.departmentId, this.organizationId, this.empId, this.userName, this.role, this.grade, this.iat, this.exp});

  JWTData.fromJson(Map<String, dynamic> json) {
    employeeId = json["employeeId"];
    companyId = json["companyId"];
    tenantId = json["tenantId"];
    branchId = json["branchId"];
    departmentId = json["departmentId"];
    organizationId = json["organizationId"];
    empId = json["empId"];
    userName = json["userName"];
    role = json["role"];
    grade = json["grade"];
    iat = json["iat"];
    exp = json["exp"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["employeeId"] = employeeId;
    _data["companyId"] = companyId;
    _data["tenantId"] = tenantId;
    _data["branchId"] = branchId;
    _data["departmentId"] = departmentId;
    _data["organizationId"] = organizationId;
    _data["empId"] = empId;
    _data["userName"] = userName;
    _data["role"] = role;
    _data["grade"] = grade;
    _data["iat"] = iat;
    _data["exp"] = exp;
    return _data;
  }
}