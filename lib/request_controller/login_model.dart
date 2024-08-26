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
  final String? employeeId;
  final String? CompanyId;
  final String? branchId;
  final String? departmentId;
  final String? organizationId;
  final String? empId;
  final String? userName;
  final String? role;
  final String? grade;
  final int? exp;
  final int? iat;

  JWTData({this.employeeId, this.CompanyId, this.branchId, this.departmentId, this.organizationId, this.empId,this.userName , this.role , this.grade , this.exp , this.iat});

  factory JWTData.fromJson(Map<String, dynamic> json) {
    return JWTData(
      employeeId: json['employeeId'],
      CompanyId: json['CompanyId'],
      branchId: json['branchId'],
      departmentId: json['departmentId'],
      organizationId: json['organizationId'],
      empId: json['empId'],
      userName: json['userName'],
      role: json['role'],
      grade: json['grade'],
      exp: json['exp'],
      iat: json['iat'],
    );
  }

  toList() {}
}