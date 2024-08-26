import 'dart:convert';
import 'package:nashr/request_controller/employee_model.dart';
import 'package:nashr/request_controller/login_model.dart';
import 'package:http/http.dart' as http;
class SingletonClass {
  factory SingletonClass() {
    if (_singleton == null) {
      _singleton = SingletonClass._();
      _singleton!.init();
    }
    return _singleton!;
  }

  SingletonClass._();

  static SingletonClass? _singleton;

  bool initialized = false;
  String? baseURL = 'https://a569-39-63-125-161.ngrok-free.app';
  LoginModel? _loginModel;
  JWTData? _jwtData;
  List<EmployeeData> employeeDataList = [];


  init() async {
    _singleton ??= SingletonClass._();
  }
 // Setters for populating data
  void setLoginModel(LoginModel loginModel) {
    _loginModel = loginModel;
  }

  void setJWTModel(JWTData jwtData) {
    _jwtData = jwtData;
  }

  void setEmployeeData(List<EmployeeData> employeeData) {
    // Method to set the company list
    employeeDataList = employeeData;
  }
  // Method to get the ResponseModel instance
  LoginModel? getLoginModel() {
    return _loginModel;
  }
  JWTData? getJWTModel() {
    return _jwtData;
  }
//API Calls

  Future<EmployeeData?> getEmployeeData() async {
    String? employeeId =  getJWTModel()?.employeeId;
    var client = http.Client();
    var uri = Uri.parse('$baseURL/employee/$employeeId');
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var employeeData = EmployeeData.fromJson(responseBody);
      setEmployeeData([employeeData]);
      return employeeData;
    }
    return null ; // Print the response body
  }
}
