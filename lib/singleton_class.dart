import 'dart:convert';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:nashr/request_controller/approver_request_data_model.dart';
import 'package:nashr/request_controller/assets_details_model.dart';
import 'package:nashr/request_controller/attachment_response_model.dart';
import 'package:nashr/request_controller/attendance_model.dart';
import 'package:nashr/request_controller/branch_model.dart';
import 'package:nashr/request_controller/check_in_model.dart';
import 'package:nashr/request_controller/clocking_model.dart';
import 'package:nashr/request_controller/company_model.dart';
import 'package:nashr/request_controller/employee_details_assets_model.dart';
import 'package:nashr/request_controller/employee_details_attendance_model.dart';
import 'package:nashr/request_controller/employee_details_clocking_model.dart';
import 'package:nashr/request_controller/employee_details_model.dart';
import 'package:nashr/request_controller/employee_model.dart';
import 'package:nashr/request_controller/login_model.dart';
import 'package:http/http.dart' as http;
import 'package:nashr/request_controller/notification_model.dart';
import 'package:nashr/request_controller/profile_response_model.dart';
import 'package:nashr/request_controller/request_data_model.dart';
import 'package:nashr/request_controller/search_employee_model.dart';
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
  String? awsURL = "https://dev.nashrms.com/api";
  String? baseURL;
  LoginModel? _loginModel;
  JWTData? _jwtData;
  List<EmployeeData> employeeDataList = [];
  List<NotificationModel> notificationModelList = [];
  List<ProfileResponse> profileResponseDataList = [];
  List<AttachmentResponse> attachmentResponseDataList = [];
  List<SearchEmployeeData> searchEmployeeDataList = [];
  List<AssetDetailsModel> assetsDetailsModel = [];
  List<EmployeeDetailsAssetsModel> employeeDetailsAssetsModel = [];
  List<EmployeeDetailsAttendanceData> employeeDetailsAttendanceDataList = [];
  List<AttendanceData> attendanceDataList = [];
  List<ApproverRequestData> approverDataList = [];
  List<CompanyData> companyDataList = [];
  List<RequestDateModel> requestDataList = [];
  List<EmployeeDetailsData> employeeDetailsDataList = [];
  List<EmployeeDetailsClocking> employeeDetailsClockingDataList = [];
  List<CheckInData> checkInDataList = [];
  List<ClockingData> clockingDataList = [];
  List<BranchData> branchDataList = [];
  String? checkInStatus ;
  String? checkOutStatus ;
  String? fcmToken;

  init() async {
    _singleton ??= SingletonClass._();
  }
 // Setters for populating data
  void setLoginModel(LoginModel loginModel) {
    _loginModel = loginModel;
  }

  void setCheckInData(List<CheckInData> checkInData) {
    // Method to set the company list
    checkInDataList = checkInData;
  }

  void setJWTModel(JWTData jwtData) {
    _jwtData = jwtData;
  }

  void setCompanyData(List<CompanyData> companyData) {
    // Method to set the company list
    companyDataList = companyData;
  }
  void setSearchEmployeeData(List<SearchEmployeeData> searchEmployeeData) {
    // Method to set the company list
    searchEmployeeDataList = searchEmployeeData;
  }
  void setEmployeeAttendanceDataList(List<EmployeeDetailsAttendanceData> attendance) {
    // Method to set the company list
    employeeDetailsAttendanceDataList = attendance;
  }


  void setApproverDataList(List<ApproverRequestData> approverReq) {
    // Method to set the company list
    approverDataList = approverReq;
  }

  void setRequestData(List<RequestDateModel> requestData) {
    // Method to set the company list
    requestDataList = requestData;
  }


  void setEmployeeData(List<EmployeeData> employeeData) {
    // Method to set the company list
    employeeDataList = employeeData;
  }

  void setAttendanceData(List<AttendanceData> attendanceData) {
    // Method to set the company list
    attendanceDataList = attendanceData;
  }


  void setEmployeeDetailsData(List<EmployeeDetailsData> employeeDetailsData) {
    // Method to set the company list
    employeeDetailsDataList = employeeDetailsData;
  }

  void setEmployeeDetailsClocking(List<EmployeeDetailsClocking> employeeClockingDetails) {
    // Method to set the company list
    employeeDetailsClockingDataList = employeeClockingDetails;
  }

  void setClockingData(List<ClockingData> clockingData) {
    // Method to set the company list
    clockingDataList = clockingData;
  }

  void setBranchData(List<BranchData> branchData) {
    // Method to set the company list
    branchDataList = branchData;
  }

  // Method to get the ResponseModel instance
  LoginModel? getLoginModel() {
    return _loginModel;
  }
  JWTData? getJWTModel() {
    return _jwtData;
  }

  void setCheckInStatus(String status) {
    checkInStatus = status;
  }

  void setCheckOutStatus(String status) {
    checkOutStatus = status;
  }

  void setBaseURL(String url) {
    baseURL = url;
  }

  void setFCMToken(String token) {
    fcmToken = token;
  }



//API Calls

  Future<EmployeeData?> getEmployeeData() async {
    String? employeeId =  getJWTModel()?.employeeId;
    var client = http.Client();
    var uri = Uri.parse('$baseURL/employee/$employeeId');
    var response = await client.get(uri);
    log(response.body);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var employeeData = EmployeeData.fromJson(responseBody);
      setEmployeeData([employeeData]);
      return employeeData;
    }
    return null ; // Print the response body
  }

  //NOTIFICATION API CALL
  Future<NotificationModel?> getNotifications() async {
    String? employeeId =  getJWTModel()?.employeeId;
    var client = http.Client();
    var uri = Uri.parse('$baseURL/notification-data/getNotificationData/$employeeId');
    var response = await client.get(uri);
    log(response.body);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var notificationData = NotificationModel.fromJson(responseBody);
      notificationModelList.addAll([notificationData]);
      return notificationData;
    }
    return null ; // Print the response body
  }

  Future<RequestDateModel?> getRequestData() async {
    String? employeeId =  getJWTModel()?.employeeId;
    var client = http.Client();
    var uri = Uri.parse('$baseURL/request/emp/$employeeId');
    var response = await client.get(uri);
    log(response.body);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var requestData = RequestDateModel.fromJson(responseBody);
      setRequestData([requestData]);
      return requestData;
    }
    return null ; // Print the response body
  }

  //ApproverDataReq API call

  Future<ApproverRequestData?> getApproverData() async {
    String? employeeId =  getJWTModel()?.employeeId;
    var client = http.Client();
    var uri = Uri.parse('$baseURL/request/approver/$employeeId');
    var response = await client.get(uri);
    log(response.body);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var requestData = ApproverRequestData.fromJson(responseBody);
      setApproverDataList([requestData]);
      return requestData;
    }
    return null ; // Print the response body
  }


  Future<CompanyData?> getCompanyData() async {
    String? companyId =  getJWTModel()?.companyId;
    var client = http.Client();
    var uri = Uri.parse('$baseURL/company/$companyId');
    var response = await client.get(uri);
    log("Company Log ??|||${response.body}");
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var companyData = CompanyData.fromJson(responseBody);
      setCompanyData([companyData]);
      return companyData;
    }
    return null ; // Print the response body
  }

  Future<ClockingData?> getClockingData() async {
    var client = http.Client();
    var uri = Uri.parse('$baseURL/c-emp-check-in-out');
    var response = await client.get(uri);
    log(response.body);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var clockingData = ClockingData.fromJson(responseBody);
      setClockingData([clockingData]);
      return clockingData;
    }
    return null ; // Print the response body
  }

  //BRANCH DATA
  Future<BranchData?> getBranchData() async {
    String? branchId = getJWTModel()?.branchId;
    var client = http.Client();
    var uri = Uri.parse('$baseURL/branches/branchId/$branchId');
    var response = await client.get(uri);
    log(response.body);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var branch = BranchData.fromJson(responseBody);
      setBranchData([branch]);
      return branch;
    }
    return null ; // Print the response body
  }

  //formated date method
  String formatDate(DateTime date) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date); // Format: YYYY-MM-DD
    final dayOfWeek = DateFormat('EEEE').format(date); // Day of the week (e.g., Monday)
    return '$dayOfWeek $formattedDate'; // Combine date and day of the week
  }

  String formatCheckInTime(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      final formattedTime = DateFormat('h:mm a').format(dateTime);
      return formattedTime;
    } catch (e) {
      print("Error formatting time: $e"); // Handle potential parsing errors
      return '';
    }
  }


  //ATTENDANCE API CALL
  Future<AttendanceData?> getEmployeeAttendanceData() async {
    String? employeeId = getJWTModel()?.employeeId;
    var client = http.Client();
    DateTime now = DateTime.now();
    DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);
    String firstDateString = '${firstDateOfMonth.month.toString().padLeft(2, '0')}-${firstDateOfMonth.day.toString().padLeft(2, '0')}-${firstDateOfMonth.year}';
    String currentDateString = '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.year}';

    var uri = Uri.parse(
        '$baseURL/c-emp-attendance/getDataByEmployeeId/$employeeId/$firstDateString/$currentDateString');

    var response = await client.get(uri);
    print("//////?????${response.body}");
    print(employeeId);
    print(firstDateString);
    print(currentDateString);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var attendance = AttendanceData.fromJson(responseBody);
      setAttendanceData([attendance]);
      return attendance;
    }

    return null;
  }


  void sendFCMToken() async {

    String? employeeId = getJWTModel()?.employeeId;
    String url = '$baseURL/notification-subscriber/updateByEmployeeId/$employeeId';

    Map<String, dynamic> data = {
      "pushNotificationId": "$fcmToken",
    };

    // Convert data to JSON string
    String jsonData = jsonEncode(data);
    log("///$jsonData");
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );
      print("<><><><>${response.body}");
      if (response.statusCode == 200) {
        print("Sexfull send");
      } else {
      }
    } catch (error) {
      print('Failed to send data. Error: $error');
    }
  }

  String formatTime(String createdAt) {
    DateTime createdDate = DateTime.parse(createdAt);
    return DateFormat('hh:mm a').format(createdDate); // e.g., "10:30 AM"
  }

  String formatDate2(String createdAt) {
    DateTime createdDate = DateTime.parse(createdAt);
    return DateFormat('dd-MM-yyyy').format(createdDate); // e.g., "01-11-2024"
  }
}


