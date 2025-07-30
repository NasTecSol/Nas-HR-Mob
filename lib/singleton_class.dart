import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:nashr/request_controller/approver_request_data_model.dart';
import 'package:nashr/request_controller/assets_details_model.dart';
import 'package:nashr/request_controller/attachment_response_model.dart';
import 'package:nashr/request_controller/attendance_model.dart';
import 'package:nashr/request_controller/base_url_model.dart';
import 'package:nashr/request_controller/branch_model.dart';
import 'package:nashr/request_controller/branch_shift_model.dart';
import 'package:nashr/request_controller/branches_data_model.dart';
import 'package:nashr/request_controller/branches_model.dart';
import 'package:nashr/request_controller/check_in_model.dart';
import 'package:nashr/request_controller/clocking_model.dart';
import 'package:nashr/request_controller/companies_data_model.dart';
import 'package:nashr/request_controller/company_assets_details_model.dart';
import 'package:nashr/request_controller/company_model.dart';
import 'package:nashr/request_controller/complaints_approver_model.dart';
import 'package:nashr/request_controller/complaints_model.dart';
import 'package:nashr/request_controller/document_notification_model.dart';
import 'package:nashr/request_controller/employee_details_assets_model.dart';
import 'package:nashr/request_controller/employee_details_attendance_model.dart';
import 'package:nashr/request_controller/employee_details_clocking_model.dart';
import 'package:nashr/request_controller/employee_details_model.dart';
import 'package:nashr/request_controller/employee_model.dart';
import 'package:nashr/request_controller/event_model.dart';
import 'package:nashr/request_controller/login_model.dart';
import 'package:http/http.dart' as http;
import 'package:nashr/request_controller/notification_model.dart';
import 'package:nashr/request_controller/penalities_fines_model.dart';
import 'package:nashr/request_controller/penalties_approver_model.dart';
import 'package:nashr/request_controller/policy_model.dart';
import 'package:nashr/request_controller/profile_response_model.dart';
import 'package:nashr/request_controller/project_logo_model.dart';
import 'package:nashr/request_controller/projects_data_model.dart';
import 'package:nashr/request_controller/remoteAttendanceModel.dart';
import 'package:nashr/request_controller/request_data_model.dart';
import 'package:nashr/request_controller/search_employee_model.dart';
import 'package:nashr/request_controller/signature_model.dart';
import 'package:nashr/request_controller/task_attachment_model.dart';
import 'package:nashr/request_controller/task_model.dart';
import 'package:nashr/request_controller/team_clocking_model.dart';
import 'package:nashr/request_controller/team_attendance_model.dart';
import 'package:nashr/request_controller/time_table_shift.dart';
import 'package:nashr/request_controller/ui_settings_model.dart';

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
  String? baseURL;
  LoginModel? _loginModel;
  JWTData? _jwtData;
  List<EmployeeData> employeeDataList = [];
  List<CompaniesDataModel> companiesDataList = [];
  List<BranchesDataModel> branchesDataList = [];
  List<DocumentNotificationModel> documentNotificationDataList = [];
  List<TenantIdModel> tenantIDDataList = [];
  List<ComplaintsApproverModel> complaintsApproverDataList = [];
  List<PenaltiesApproverModel> penaltiesApproverDataList = [];
  List<SignatureModel> signatureModelList = [];
  List<RemoteAttendanceModel> remoteAttendanceModelList = [];
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
  List<TeamAttendanceModel> teamAttendanceDataList = [];
  List<ApproverRequestData> approverDataList = [];
  List<CompanyData> companyDataList = [];
  List<RequestDataModel> requestDataList = [];
  List<EmployeeDetailsData> employeeDetailsDataList = [];
  List<EmployeeDetailsClocking> employeeDetailsClockingDataList = [];
  List<CheckInData> checkInDataList = [];
  List<ClockingData> clockingDataList = [];
  List<TeamClockingModel> teamClockingDataList = [];
  List<BranchData> branchDataList = [];
  List<EventModel> eventDataList = [];
  List<PolicyModel> policyModelDataList = [];
  List<UiSettingsModel> uiSettingsModelDataList = [];
  List<BranchShiftModel> branchShiftsDataList = [];
  List<TimeTableShiftModel> timeTableShiftsDataList = [];
  List<BranchesModel> branchesModelDataList = [];
  List<CompanyAssetsDetailsModel> companyAssetsDataList = [];
  String? checkInStatus ;
  String? selectedCompanyId ;
  String? checkOutStatus ;
  String? fcmToken;
  String? tenantId;
  String? companyName;
  String? branchID;
  String? branchName;

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

  void setRequestData(List<RequestDataModel> requestData) {
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

  void setFCMToken(String token) {
    fcmToken = token;
  }



//API Calls
  Future<CompaniesDataModel?> getCompaniesData() async {
    String? organizationId =  getJWTModel()?.organizationId;
    var client = http.Client();
    var uri = Uri.parse('$baseURL/organization/$organizationId');
    var response = await client.get(uri , headers: getHeaders());
    log("organization Companies Data ${response.body}");
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var companiesData = CompaniesDataModel.fromJson(responseBody);
      companiesDataList.addAll([companiesData]);
      return companiesData;
    }
    return null ; // Print the response body
  }


  Future<UiSettingsModel?> getUISettingsData() async {
    String? employeeId =  getJWTModel()?.employeeId;
    String? grade =  getJWTModel()?.grade;
    var client = http.Client();
    var uri = Uri.parse('$baseURL/organization/getUiSettings/$employeeId/$grade');
    var response = await client.get(
        uri,
        headers: getHeaders()
    );
    log("UI SETTINGS DATA ${response.body}");
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var uiSettingsData = UiSettingsModel.fromJson(responseBody);
      uiSettingsModelDataList.addAll([uiSettingsData]);
      return uiSettingsData;
    }
    return null ; // Print the response body
  }

  Future<PolicyModel?> getPolicyData() async {
    String? policyId =  companyDataList.first.data!.policies!.first.policyId;
    var client = http.Client();
    var uri = Uri.parse('$baseURL/policies/$policyId');
    var response = await client.get(uri,
        headers: getHeaders());
    log("POLICY DATA ${response.body}");
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var policyData = PolicyModel.fromJson(responseBody);
      policyModelDataList.addAll([policyData]);
      return policyData;
    }
    return null ; // Print the response body
  }

  Future<EmployeeData?> getEmployeeData() async {
    String? employeeId =  getJWTModel()?.employeeId;
    var client = http.Client();
    var uri = Uri.parse('$baseURL/employee/$employeeId');
    var response = await client.get(uri,headers: getHeaders());
    log("EMPLOYEE DATA ${response.body}");
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var employeeData = EmployeeData.fromJson(responseBody);
      setEmployeeData([employeeData]);
      return employeeData;
    }
    return null ; // Print the response body
  }

  //Remote Attendance Data
  Future<RemoteAttendanceModel?> getRemoteAttendanceData() async {
    String? employeeId =  getJWTModel()?.employeeId;
    var client = http.Client();
    var uri = Uri.parse('$baseURL/employee/getEMPRemoteLocation/$employeeId');
    var response = await client.get(uri,headers: getHeaders());
    log("Remote Attendance Data : ${response.body}");
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var remoteData = RemoteAttendanceModel.fromJson(responseBody);
      remoteAttendanceModelList.addAll([remoteData]);
      return remoteData;
    }
    return null ; // Print the response body
  }

  //NOTIFICATION API CALL
  Future<NotificationModel?> getNotifications() async {
    String? employeeId =  getJWTModel()?.employeeId;
    var client = http.Client();
    var uri = Uri.parse('$baseURL/notification-data/getNotificationData/$employeeId');
    var response = await client.get(uri,headers: getHeaders());
    log(response.body);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var notificationData = NotificationModel.fromJson(responseBody);
      notificationModelList.addAll([notificationData]);
      return notificationData;
    }
    return null ; // Print the response body
  }

  Future<CompanyData?> getCompanyData() async {
    String? companyId = (selectedCompanyId != null && selectedCompanyId!.isNotEmpty)
        ? selectedCompanyId
        : getJWTModel()?.companyId;

    if (companyId == null || companyId.isEmpty) {
      log("❌ No companyId available from selectedCompanyId or JWT!");
      return null;
    }


    var client = http.Client();
    var uri = Uri.parse('$baseURL/company/$companyId');

    log("📡 Requesting company data from: $uri");
    log("📦 Headers: ${getHeaders()}");

    try {
      var response = await client.get(uri, headers: getHeaders());
      log("📥 Company Response: ${response.statusCode} || ${response.body}");

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        var companyData = CompanyData.fromJson(responseBody);
        setCompanyData([companyData]);
        return companyData;
      } else {
        log("❌ Failed to fetch company data. Status: ${response.statusCode}");
      }
    } catch (e) {
      log("❗ Exception while calling company API: $e");
    }

    return null;
  }


  Future<ClockingData?> getClockingData() async {
    String? employeeId = getJWTModel()?.employeeId;
    var client = http.Client();
    DateTime now = DateTime.now();
    DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);
    String firstDateString = '${firstDateOfMonth.month.toString().padLeft(2, '0')}-${firstDateOfMonth.day.toString().padLeft(2, '0')}-${firstDateOfMonth.year}';
    String currentDateString = '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.year}';

    var uri = Uri.parse('$baseURL/c-emp-check-in-out/filter?employeeId=$employeeId&startDate=$firstDateString&endDate=$currentDateString');
    if (kDebugMode) {
      print(uri);
    }
    var response = await client.get(uri,headers: getHeaders());
    log("ClockingData singleton:${response.body}");
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var clockingData = ClockingData.fromJson(responseBody);
      setClockingData([clockingData]);
      return clockingData;
    }
    return null ;
  }

  //BRANCH DATA
  Future<BranchData?> getBranchData() async {
    String? branchId = getJWTModel()?.branchId;
    var client = http.Client();
    var uri = Uri.parse('$baseURL/branches/branchId/$branchId');
    var response = await client.get(uri,headers: getHeaders());
    log("Branch Data List ${response.body}");
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var branch = BranchData.fromJson(responseBody);
      setBranchData([branch]);
      return branch;
    }
    return null ; // Print the response body
  }

  Future<BranchesDataModel?> getBranchesData() async {
    String? companyId = (selectedCompanyId != null && selectedCompanyId!.isNotEmpty)
        ? selectedCompanyId
        : getJWTModel()?.companyId;

    if (companyId == null || companyId.isEmpty) {
      log("❌ No companyId available from selectedCompanyId or JWT!");
      return null;
    }

    var client = http.Client();
    var uri = Uri.parse('$baseURL/branches/companyId/$companyId');

    log("📡 Requesting branches for companyId: $companyId");
    log("🔗 URL: $uri");

    try {
      var response = await client.get(uri, headers: getHeaders());
      log("📥 Branches Data Response: ${response.statusCode} || ${response.body}");

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        var branch = BranchesDataModel.fromJson(responseBody);
        branchesDataList.add(branch);
        return branch;
      } else {
        log("❌ Failed to fetch branches. Status: ${response.statusCode}");
      }
    } catch (e) {
      log("❗ Exception while fetching branches: $e");
    }

    return null;
  }


  //formated date method
  String formatDate(DateTime date) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date); // Format: YYYY-MM-DD
    final dayOfWeek = DateFormat('EEEE').format(date); // Day of the week (e.g., Monday)
    return '$dayOfWeek $formattedDate'; // Combine date and day of the week
  }

  String formatCheckInTime(String dateTimeString) {
    try {
      DateTime localTime = DateTime.parse(dateTimeString).toLocal();

      final formattedTime = DateFormat('h:mm a').format(localTime);
      return formattedTime;
    } catch (e) {
      if (kDebugMode) {
        print("Error formatting time: $e");
      }
      return 'N/A';
    }
  }
  //ATTENDANCE API CALL
  Future<AttendanceData?> getEmployeeAttendanceData({
    int limit = 31,
    int page = 0,
  }) async {
    String? employeeId = getJWTModel()?.employeeId;
    var client = http.Client();
    DateTime now = DateTime.now();
    DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);
    String firstDateString = '${firstDateOfMonth.month.toString().padLeft(2, '0')}-${firstDateOfMonth.day.toString().padLeft(2, '0')}-${firstDateOfMonth.year}';
    String currentDateString = '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.year}';

    var uri = Uri.parse(
        '$baseURL/c-emp-attendance/getDataByEmployeeId/$employeeId/$currentDateString/$firstDateString?limit=$limit&page=$page');

    var response = await client.get(uri,headers: getHeaders());
    log("attendance of user${response.body}");
    if (kDebugMode) {
      print(employeeId);
      print(firstDateString);
      print(currentDateString);
    }
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
        headers: getHeaders(),
        body: jsonData,
      );
      if (kDebugMode) {
        print("<><><><>${response.body}");
      }
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("Sexfull send");
        }
      } else {
      }
    } catch (error) {
      if (kDebugMode) {
        print('Failed to send data. Error: $error');
      }
    }
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
      return DateFormat('hh:mm:a').format(parsedDate);
    } catch (e) {
      return 'Invalid date';
    }
  }

  String formatMinutes(int totalMinutes) {
    int hours = totalMinutes ~/ 60;  // Get hours
    int minutes = totalMinutes % 60; // Get remaining minutes
    return "$hours h $minutes min";  // Return formatted string
  }

  bool isToday(String? datetimeString) {
    if (datetimeString == null || datetimeString.isEmpty) return false;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return datetimeString.startsWith(today);
  }


  //Header for api call

  Map<String, String> getHeaders() {
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "x-tenant-id" : tenantId.toString()
    };
  }
}


