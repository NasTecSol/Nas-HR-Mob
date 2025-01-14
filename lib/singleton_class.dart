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
import 'package:nashr/request_controller/complaints_approver_model.dart';
import 'package:nashr/request_controller/complaints_model.dart';
import 'package:nashr/request_controller/employee_details_assets_model.dart';
import 'package:nashr/request_controller/employee_details_attendance_model.dart';
import 'package:nashr/request_controller/employee_details_clocking_model.dart';
import 'package:nashr/request_controller/employee_details_model.dart';
import 'package:nashr/request_controller/employee_model.dart';
import 'package:nashr/request_controller/login_model.dart';
import 'package:http/http.dart' as http;
import 'package:nashr/request_controller/notification_model.dart';
import 'package:nashr/request_controller/penalities_fines_model.dart';
import 'package:nashr/request_controller/penalties_approver_model.dart';
import 'package:nashr/request_controller/profile_response_model.dart';
import 'package:nashr/request_controller/project_logo_model.dart';
import 'package:nashr/request_controller/projects_data_model.dart';
import 'package:nashr/request_controller/request_data_model.dart';
import 'package:nashr/request_controller/search_employee_model.dart';
import 'package:nashr/request_controller/task_attachment_model.dart';
import 'package:nashr/request_controller/task_model.dart';
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
  List<ComplaintsApproverModel> complaintsApproverDataList = [];
  List<PenaltiesApproverModel> penaltiesApproverDataList = [];
  List<ProjectsData> projectsDataList = [];
  List<TaskAttachmentModel> taskAttachmentDataList = [];
  List<TaskModel> taskModelList = [];
  List<ProjectLogoModel> projectsLogoModelList = [];
  List<PenaltiesAndFineModel> penaltiesDataList = [];
  List<NotificationModel> notificationModelList = [];
  List<ComplaintsModel> complaintsDataList = [];
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
    String? employeeId = getJWTModel()?.employeeId;

    // Request body with the required parameter
    Map<String, dynamic> requestBody = {
      "requestTypes": ["leaveRequest","loanRequest"],
    };

    var uri = Uri.parse('$baseURL/request/employee/$employeeId');

    try {
      final response = await http.post(
        uri,
        body: json.encode(requestBody),
        headers: {
          "Content-Type": "application/json",
          "accept": "application/json",
        },
      );

      log("Request Log: ${response.body}");

      if (response.statusCode == 201) {
        // Parse the response body
        var responseBody = json.decode(response.body);
        var requestData = RequestDateModel.fromJson(responseBody);

        // Set the data into the application state (singleton or other storage)
        setRequestData([requestData]);

        // Print the parsed data for debugging
        print(
            "Singleton Data: ${requestDataList.first.data!.first.employeeName}");

        return requestData;
      } else {
        log("Error: Received status code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log('Error: $e');
      return null;
    }
  }


  Future<ComplaintsModel?> getComplaintsData() async {
    String? employeeId = getJWTModel()?.employeeId;

    // Request body with the required parameter
    Map<String, dynamic> requestBody = {
      "requestTypes": ["complaintRequest"],
    };

    var uri = Uri.parse('$baseURL/request/employee/$employeeId');

    try {
      final response = await http.post(
        uri,
        body: json.encode(requestBody),
        headers: {
          "Content-Type": "application/json",
          "accept": "application/json",
        },
      );

      log("Complaints Log: ${response.body}");

      if (response.statusCode == 201) {
        // Parse the response body
        var responseBody = json.decode(response.body);
        var requestData = ComplaintsModel.fromJson(responseBody);

        // Set the data into the application state (singleton or other storage)
        complaintsDataList.addAll([requestData]);
        return requestData;
      } else {
        log("Error: Received status code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log('Error: $e');
      return null;
    }
  }

  Future<PenaltiesAndFineModel?> getPenalties() async {
    String? employeeId =  getJWTModel()?.empId;
    var client = http.Client();
    var uri = Uri.parse('$baseURL/request/penalties_fines/$employeeId');
    var response = await client.get(uri);
    log(response.body);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var requestData = PenaltiesAndFineModel.fromJson(responseBody);
      penaltiesDataList.addAll([requestData]);
      return requestData;
    }
    return null ; // Print the response body
  }
  //ApproverDataReq API call

  Future<ApproverRequestData?> getApproverData() async {
    String? employeeId = getJWTModel()?.employeeId;
    Map<String, dynamic> requestBody = {
      "requestTypes": ["leaveRequest","loanRequest"],
    };
    var uri = Uri.parse('$baseURL/request/approver/$employeeId');

    try {
      final response = await http.post(
        uri,
        body: json.encode(requestBody),
        headers: {
          "Content-Type": "application/json",
          "accept": "application/json",
        },
      );

      log("Request Log approver: ${response.body}");

      if (response.statusCode == 201) {
        // Parse the response body
        var responseBody = json.decode(response.body);
        var requestData = ApproverRequestData.fromJson(responseBody);

        // Set the data into the application state (singleton or other storage)
        setApproverDataList([requestData]);

        // Print the parsed data for debugging
        print(
            "Singleton Data approver: ${approverDataList.first.data!.first.employeeName}");

        return requestData;
      } else {
        log("Error: Received status code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log('Error: $e');
      return null;
    }
  }

  //Approver for complaints
  Future<ComplaintsApproverModel?> getComplaintsApproverData() async {
    String? employeeId = getJWTModel()?.employeeId;
    Map<String, dynamic> requestBody = {
      "requestTypes": ["complaintRequest"],
    };
    var uri = Uri.parse('$baseURL/request/approver/$employeeId');

    try {
      final response = await http.post(
        uri,
        body: json.encode(requestBody),
        headers: {
          "Content-Type": "application/json",
          "accept": "application/json",
        },
      );

      log("complaints Log approver: ${response.body}");

      if (response.statusCode == 201) {
        // Parse the response body
        var responseBody = json.decode(response.body);
        var requestData = ComplaintsApproverModel.fromJson(responseBody);

        // Set the data into the application state (singleton or other storage)
        complaintsApproverDataList.addAll([requestData]);
        return requestData;
      } else {
        log("Error: Received status code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log('Error: $e');
      return null;
    }
  }

  //Approver for penalties
  Future<PenaltiesApproverModel?> getPenaltiesApprover() async {
    String? employeeId = getJWTModel()?.employeeId;
    Map<String, dynamic> requestBody = {
      "requestTypes": ["penalties_fines"],
    };
    var uri = Uri.parse('$baseURL/request/approver/$employeeId');

    try {
      final response = await http.post(
        uri,
        body: json.encode(requestBody),
        headers: {
          "Content-Type": "application/json",
          "accept": "application/json",
        },
      );

      log("penalties Log approver: ${response.body}");

      if (response.statusCode == 201) {
        // Parse the response body
        var responseBody = json.decode(response.body);
        var requestData = PenaltiesApproverModel.fromJson(responseBody);

        // Set the data into the application state (singleton or other storage)
        penaltiesApproverDataList.addAll([requestData]);
        return requestData;
      } else {
        log("Error: Received status code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log('Error: $e');
      return null;
    }
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
    String? employeeId = getJWTModel()?.employeeId;
    var client = http.Client();
    DateTime now = DateTime.now();
    DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);
    String firstDateString = '${firstDateOfMonth.month.toString().padLeft(2, '0')}-${firstDateOfMonth.day.toString().padLeft(2, '0')}-${firstDateOfMonth.year}';
    String currentDateString = '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.year}';

    var uri = Uri.parse('$baseURL/c-emp-check-in-out/$employeeId/$firstDateString/$currentDateString');
    var response = await client.get(uri);
    log("ClockingData:${response.body}");
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

  Future<TaskModel?> getTasks() async {
    var client = http.Client();
    var uri = Uri.parse('${baseURL}/kanban-task');
    var response = await client.get(uri);
    log("Task Data Log ${response.body}");
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var taskData = TaskModel.fromJson(responseBody);
      taskModelList.addAll([taskData]);
      return taskData;
    }
    return null ; // Print the response body
  }

  String formatTime(String createdAt) {
    DateTime createdDate = DateTime.parse(createdAt);
    return DateFormat('hh:mm a').format(createdDate);
  }

  String formatDate2(String createdAt) {
    DateTime createdDate = DateTime.parse(createdAt);
    return DateFormat('dd-MM-yyyy').format(createdDate);
  }

  String formatDateTime(String dateTime) {
    try {
      final parsedDate = DateTime.parse(dateTime).toLocal();
      return DateFormat('dd-MM-yyyy hh:mm:a').format(parsedDate);
    } catch (e) {
      return 'Invalid date';
    }
  }
}


