import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:nashr/request_controller/approver_request_data_model.dart';
import 'package:nashr/request_controller/assets_details_model.dart';
import 'package:nashr/request_controller/attachment_response_model.dart';
import 'package:nashr/request_controller/attendance_model.dart';
import 'package:nashr/request_controller/base_url_model.dart';
import 'package:nashr/request_controller/biometric_devices_model.dart';
import 'package:nashr/request_controller/branch_model.dart';
import 'package:nashr/request_controller/branch_shift_model.dart';
import 'package:nashr/request_controller/branches_data_model.dart';
import 'package:nashr/request_controller/branches_model.dart';
import 'package:nashr/request_controller/check_in_model.dart';
import 'package:nashr/request_controller/clocking_model.dart';
import 'package:nashr/request_controller/companies_data_model.dart';
import 'package:nashr/request_controller/company_assets_details_model.dart';
import 'package:nashr/request_controller/company_details_document_notification_model.dart';
import 'package:nashr/request_controller/company_model.dart';
import 'package:nashr/request_controller/company_notification_model.dart';
import 'package:nashr/request_controller/company_notifications_assets_detail_model.dart';
import 'package:nashr/request_controller/complaints_approver_model.dart';
import 'package:nashr/request_controller/complaints_model.dart';
import 'package:nashr/request_controller/document_notification_model.dart';
import 'package:nashr/request_controller/document_shared_template.dart';
import 'package:nashr/request_controller/employee_details_assets_model.dart';
import 'package:nashr/request_controller/employee_details_attendance_model.dart';
import 'package:nashr/request_controller/employee_details_clocking_model.dart';
import 'package:nashr/request_controller/employee_details_model.dart';
import 'package:nashr/request_controller/employee_model.dart';
import 'package:nashr/request_controller/event_model.dart';
import 'package:nashr/request_controller/login_model.dart';
import 'package:http/http.dart' as http;
import 'package:nashr/request_controller/notification_model.dart';
import 'package:nashr/request_controller/organization_model.dart';
import 'package:nashr/request_controller/penalities_fines_model.dart';
import 'package:nashr/request_controller/penalties_approver_model.dart';
import 'package:nashr/request_controller/policy_model.dart';
import 'package:nashr/request_controller/profile_response_model.dart';
import 'package:nashr/request_controller/project_logo_model.dart';
import 'package:nashr/request_controller/projects_data_model.dart';
import 'package:nashr/request_controller/remoteAttendanceModel.dart';
import 'package:nashr/request_controller/report_manager_model.dart';
import 'package:nashr/request_controller/request_data_model.dart';
import 'package:nashr/request_controller/role_and_access_model.dart';
import 'package:nashr/request_controller/search_employee_model.dart';
import 'package:nashr/request_controller/signature_model.dart';
import 'package:nashr/request_controller/slack_model.dart';
import 'package:nashr/request_controller/socket_model.dart';
import 'package:nashr/request_controller/stores_model.dart';
import 'package:nashr/request_controller/task_attachment_model.dart';
import 'package:nashr/request_controller/task_model.dart';
import 'package:nashr/request_controller/team_clocking_model.dart';
import 'package:nashr/request_controller/team_attendance_model.dart';
import 'package:nashr/request_controller/team_model.dart';
import 'package:nashr/request_controller/time_table_shift.dart';
import 'package:nashr/request_controller/ui_settings_model.dart';
import 'package:nashr/request_controller/user_activity_detail_model.dart';
import 'package:nashr/request_controller/user_activity_model.dart';
import 'package:nashr/widgets/face_id_popup.dart';
import 'package:nashr/widgets/successful_popup.dart';
import 'package:nashr/widgets/unsuccessful_popup.dart';

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
  String? env;
  String? envToggle;
  int unreadCount = 0;
  bool? isTimerActive = false;
  LoginModel? _loginModel;
  JWTData? _jwtData;
  List<EmployeeData> employeeDataList = [];
  List<UserActivityDetailModel> userActivityDetailModelDataList = [];
  List<UserActivityModel> userActivityDataList = [];
  List<CompanyNotificationModel> companyNotificationDataList = [];
  List<CompanyNotificationsAssetsDetailModel> companyNotificationAssetDetailDataList = [];
  List<DocumentSharedTemplate> documentSharedTemplateDataList = [];
  List<ReportManagerModel> reportManagerDataList = [];
  List<RoleAndAccessModel> roleAndAccessModelDataList = [];
  List<BiometricDevicesModel> biometricDevicesModelDataList = [];
  List<OrganizationModel> organizationModelDataList = [];
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
  int totalApprovedRequestsCount = 0;
  int totalPendingApprovalsCount = 0;
  List<EmployeeDetailsData> employeeDetailsDataList = [];
  List<EmployeeDetailsClocking> employeeDetailsClockingDataList = [];
  List<CheckInData> checkInDataList = [];
  List<ClockingData> clockingDataList = [];
  List<TeamClockingModel> teamClockingDataList = [];
  List<BranchData> branchDataList = [];
  List<TeamModel> teamBranchDataList = [];
  List<EventModel> eventDataList = [];
  List<PolicyModel> policyModelDataList = [];
  List<UiSettingsModel> uiSettingsModelDataList = [];
  List<BranchShiftModel> branchShiftsDataList = [];
  List<TimeTableShiftModel> timeTableShiftsDataList = [];
  List<BranchesModel> branchesModelDataList = [];
  List<CompanyAssetsDetailsModel> companyAssetsDataList = [];
  List<CompanyDetailsDocumentNotificationModel> companyDetailDocumentNotificationDataList = [];
  List<SocketModel> socketDataList = [];
  List<SlackModel> slackDataList = [];
  List<StoresModel> storeModelDataList = [];
  String? checkInStatus ;
  String? selectedCompanyId ;
  String? checkOutStatus ;
  String? fcmToken;
  String? tenantId;
  String? tenantLogo;
  String? companyName;
  String? branchID;
  String? branchName;
  String? activeChatRoomId;
  String? activeScreen;
  List<dynamic> availableBranches = [];
  List<Map<String, String>> chatMessages = [];
  bool hasShownGreeting = false;
  bool isFirstTimeSelectionDone = false;
  String? local;
  String headerUrl = '';
  String footerUrl = '';
  String? token ;
  bool? rememberMe = true ;

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
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var companiesData = CompaniesDataModel.fromJson(responseBody);
      companiesDataList.addAll([companiesData]);
      return companiesData;
    }
    return null ;
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
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var uiSettingsData = UiSettingsModel.fromJson(responseBody);
      uiSettingsModelDataList.addAll([uiSettingsData]);
      return uiSettingsData;
    }
    return null ;
  }

  ///Get HR letter Template
  Future<DocumentSharedTemplate?> getHRLetter() async {
    var client = http.Client();
    var uri = Uri.parse('$baseURL/documents/getBytemplateType?templateType=Doc_editor_shared&page=0&limit=100');
    var response = await client.get(
        uri,
        headers: getHeaders()
    );
    log("GET HR LETTER${response.body}");
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var documentSharedTemplateData = DocumentSharedTemplate.fromJson(responseBody);
      documentSharedTemplateDataList.addAll([documentSharedTemplateData]);
      return documentSharedTemplateData;
    }
    return null;
  }

  /// Organization call
  Future<OrganizationModel?> getOrganizationData() async {
    String? organizationID = getJWTModel()?.organizationId;
    if (organizationID == null) {
      debugPrint("⚠️ Organization ID not found");
      return null;
    }

    final uri = Uri.parse('$baseURL/ui-modules/get-org-heirarchy/$organizationID');
    final response = await http.get(uri, headers: getHeaders());

    if (response.statusCode == 200) {
      debugPrint("ORGANIZATION DATA: ${response.body}");
      final responseBody = json.decode(response.body);
      final organizationData = OrganizationModel.fromJson(responseBody);

      organizationModelDataList.clear(); // avoid duplicates
      organizationModelDataList.add(organizationData);

      if (organizationModelDataList.first.data?.companies?.isNotEmpty == true) {
        print("======== ${organizationModelDataList.first.data!.companies!.first.name}");
      } else {
        print("⚠️ No organization data parsed!");
      }

      return organizationData;
    } else {
      print("❌ Failed to load data: ${response.statusCode}");
    }
    return null;
  }
  ///Role and Access Api Call
  Future<RoleAndAccessModel?> getRoleAndAccessData() async {
    String? employeeId = getJWTModel()?.employeeId;
    String? grade = getJWTModel()?.grade;

    var uri = Uri.parse('$baseURL/ui-modules/get-ui-settings/$employeeId/$grade');
    var response = await http.get(uri, headers: getHeaders());

    if (response.statusCode == 200) {

      try {
        var jsonBody = jsonDecode(response.body);
        log("🔍 data field type: ${jsonBody['data'].runtimeType}");
        if (jsonBody['data'] is Map) {
          log("✅ data is a Map");
        } else if (jsonBody['data'] is List) {
          log("✅ data is a List — length: ${(jsonBody['data'] as List).length}");
        }

        var roleAndAccessData = RoleAndAccessModel.fromJson(jsonBody);

        roleAndAccessModelDataList
          ..clear()
          ..add(roleAndAccessData);

        log("✅ RoleAndAccessModel parsed successfully");
        log("✅ UI Modules Count: ${roleAndAccessData.data?.uiSettings?.uiModules?.length ?? 0}");
        return roleAndAccessData;
      } catch (e, st) {
        log("❌ Error loading Role & Access data: $e");
        log(st.toString());
      }
    } else {
      log("❌ API Error: ${response.statusCode}");
    }

    return null;
  }




  Future<PolicyModel?> getPolicyData() async {
    String? policyId =  companyDataList.first.data!.policies!.first.policyId;
    var client = http.Client();
    var uri = Uri.parse('$baseURL/policies/$policyId');
    var response = await client.get(uri,
        headers: getHeaders());
    if (response.statusCode == 200) {
      log("policyDAta ${response.body}");
      var responseBody = json.decode(response.body);
      var policyData = PolicyModel.fromJson(responseBody);
      policyModelDataList.clear();
      policyModelDataList.addAll([policyData]);
      return policyData;
    }
    return null ;
  }

  Future<CompanyNotificationModel?> getCompanyNotificationData() async {
    var client = http.Client();
    var uri = Uri.parse('$baseURL/doc-notifications');
    var response = await client.get(uri,
        headers: getHeaders());
    if (response.statusCode == 200) {
      log("company Notification ${response.body}");
      var responseBody = json.decode(response.body);
      var companyNotification = CompanyNotificationModel.fromJson(responseBody);
      companyNotificationDataList.clear();
      companyNotificationDataList.addAll([companyNotification]);
      return companyNotification;
    }
    return null ;
  }
  Future<EmployeeData?> getEmployeeData() async {
    try {
      String? employeeId = getJWTModel()?.empId;

      var uri = Uri.parse('$baseURL/employee/getDataByEMPId/$employeeId');
      var response = await http.get(uri, headers: getHeaders());

      log("EMPLOYEE DATA RAW: ${response.body}");

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        final employeeData = EmployeeData.fromJson(responseBody);

        setEmployeeData([employeeData]);

        // SAFE access now
        if (employeeData.data.isNotEmpty) {
          log("USERNAME: ${employeeData.data.first.userName}");
        }

        return employeeData;
      }
    } catch (e, st) {
      log("EMPLOYEE API ERROR: $e");
      log("$st");
    }

    return null;
  }

  //Remote Attendance Data
  Future<RemoteAttendanceModel?> getRemoteAttendanceData() async {
    String? employeeId =  getJWTModel()?.employeeId;
    var client = http.Client();
    var uri = Uri.parse('$baseURL/employee/getEMPRemoteLocation/$employeeId');
    var response = await client.get(uri,headers: getHeaders());
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var remoteData = RemoteAttendanceModel.fromJson(responseBody);
      remoteAttendanceModelList.addAll([remoteData]);
      return remoteData;
    }
    return null ;
  }

  ///Get supervisor Data
  Future<ReportManagerModel?> getSupervisorData() async {
    String? employeeId =  employeeDataList.first.data.first.employeeInfo!.first.reportingManager;
    var client = http.Client();
    var uri = Uri.parse('$baseURL/employee/getDataByEMPId/$employeeId');
    var response = await client.get(uri,headers: getHeaders());
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var reportManagerData = ReportManagerModel.fromJson(responseBody);
      reportManagerDataList.addAll([reportManagerData]);
      return reportManagerData;
    }
    return null ;
  }

  //NOTIFICATION API CALL
  Future<NotificationModel?> getNotifications() async {
    String? employeeId =  getJWTModel()?.employeeId;
    var client = http.Client();
    var uri = Uri.parse('$baseURL/notification-data/getNotificationData/$employeeId');
    print(uri);
    var response = await client.get(uri,headers: getHeaders());
    if (response.statusCode == 200) {
      log("notification response ${response.body}");
      var responseBody = json.decode(response.body);
      var notificationData = NotificationModel.fromJson(responseBody);
      notificationModelList.addAll([notificationData]);
      return notificationData;
    }
    return null ; // Print the response body
  }

  Future<CompanyData?> getCompanyData() async {
    String? companyId =  (selectedCompanyId != null && selectedCompanyId!.isNotEmpty)
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
    log("📦 FCM: ${fcmToken}");

    try {
      var response = await client.get(uri, headers: getHeaders());
      log("📥 Company Response: ${response.statusCode} || ${response.body}");

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        var companyData = CompanyData.fromJson(responseBody);
        setCompanyData([companyData]);
        headerUrl = "${companyData.data!.headerFooter!.defaultHeader}";
        footerUrl = "${companyData.data!.headerFooter!.defaultFooter}";
        print("HEADER${headerUrl}");
        print("footer${footerUrl}");
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
    String? branchId = (branchID != null && branchID!.isNotEmpty)
        ? branchID
        : getJWTModel()?.branchId;
    var client = http.Client();
    var uri = Uri.parse('$baseURL/branches/branchId/$branchId');
    print(uri);
    var response = await client.get(uri,headers: getHeaders());
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var branch = BranchData.fromJson(responseBody);
      setBranchData([branch]);
      return branch;
    }
    return null ;
  }

  Future<TeamModel?> getTeamBranchData() async {
    String? branchId = (branchID != null && branchID!.isNotEmpty)
        ? branchID
        : getJWTModel()?.branchId;
    var client = http.Client();
    var uri = Uri.parse('$baseURL/branches/branchEmplyeesInfo/$branchId');
    var response = await client.get(uri,headers: getHeaders());
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      var branch = TeamModel.fromJson(responseBody);
      teamBranchDataList.clear();
      teamBranchDataList.add(branch);
      return branch;
    }
    return null ;
  }
  ///API METHOD
  Future<BiometricDevicesModel?> getBiometricDevices() async {
    var client = http.Client();
    var uri = Uri.parse('$baseURL/biometric-int');
    var response = await client.get(
        uri,
        headers: getHeaders()
    );
    if (response.statusCode == 200) {
      print("BIOMETRIC DEVICES >>><<<${response.body}");
      var responseBody = json.decode(response.body);
      var bioMetricDevices = BiometricDevicesModel.fromJson(responseBody);
      biometricDevicesModelDataList.clear();
      biometricDevicesModelDataList.addAll([bioMetricDevices]);
      return bioMetricDevices;
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
        branchesDataList.clear();
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


  ///formated date method
  String formatCheckInTime(String? dateTimeString , context) {
    if (dateTimeString == null || dateTimeString.isEmpty || dateTimeString == 'null') {
      return '--:--';
    }
    try {
      DateTime? parsed = DateTime.tryParse(dateTimeString);
      if (parsed == null) return '--:--';
      DateTime localTime = parsed.toLocal();
      final locale = Localizations.localeOf(context).languageCode;
      if (locale == 'ar') {
        final arabicFormatter = DateFormat('h:mm a', 'ar');
        return arabicFormatter.format(localTime);
      } else {
        final formattedTime = DateFormat('h:mm a').format(localTime);
        return formattedTime;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error formatting time: $e");
      }
      return '--:--';
    }
  }
  /// API METHODS
  Future<SlackModel?> getChats() async {
    String? employeeId = getJWTModel()?.employeeId;
    var client = http.Client();
    var uri = Uri.parse(
        '$baseURL/chat-system/user-chats/$employeeId');
    var response = await client.get(uri, headers: getHeaders());
    if (response.statusCode == 200) {
      print("CHAT'S RESPONSE${response.body}");
      slackDataList.clear();
      var responseBody = json.decode(response.body);
      var chats = SlackModel.fromJson(responseBody);
      slackDataList.addAll([chats]);
      return  chats;
    }
    return null;
  }
  ///ATTENDANCE API CALL
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

    String jsonData = jsonEncode(data);
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: getHeaders(),
        body: jsonData,
      );
      if (kDebugMode) {
        print(url);
        print("<><FCM><><>${response.body}");
      }
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print("send");
        }
      } else {
      }
    } catch (error) {
      if (kDebugMode) {
        print('Failed to send data. Error: $error');
      }
    }
  }

  String formatTime(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty || createdAt == 'null') {
      return '--:--';
    }
    try {
      DateTime? parsed = DateTime.tryParse(createdAt);
      if (parsed == null) return '--:--';
      return DateFormat('hh:mm a').format(parsed);
    } catch (e) {
      return '--:--';
    }
  }

  String formatDate2(String? createdAt , context) {
    if (createdAt == null || createdAt.isEmpty || createdAt == 'null') {
      return '--:--';
    }
    try {
      DateTime? parsed = DateTime.tryParse(createdAt);
      if (parsed == null) return '--:--';
      final locale = Localizations.localeOf(context).languageCode;
      if (locale == 'ar') {
        final arabicFormatter = DateFormat('dd-MM-yyyy', 'ar');
        return arabicFormatter.format(parsed);
      } else {
        final formattedTime = DateFormat('dd-MM-yyyy').format(parsed);
        return formattedTime;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error formatting time: $e");
      }
      return '--:--';
    }
  }

  String formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty || dateTime == 'null') {
      return 'Invalid date';
    }
    try {
      DateTime? parsed = DateTime.tryParse(dateTime);
      if (parsed == null) return 'Invalid date';
      final parsedDate = parsed.toLocal();
      return DateFormat('hh:mm:a').format(parsedDate);
    } catch (e) {
      return 'Invalid date';
    }
  }

  String formatMinutes(int totalMinutes, context) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    return "$hours ${AppLocalizations.of(context)!.h} $minutes ${AppLocalizations.of(context)!.m}";
  }

  bool isToday(String? datetimeString) {
    if (datetimeString == null || datetimeString.isEmpty) return false;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return datetimeString.startsWith(today);
  }

  String formatWithDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '--';
    try {
      DateTime parsed = DateTime.parse(dateTimeString).toLocal();
      return DateFormat('dd MMM yyyy, h:mm a').format(parsed);
    } catch (e) {
      return '---';
    }
  }
  ///Header for api call
  Map<String, String> getHeaders() {

    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "x-tenant-id" : tenantId.toString(),
      "Authorization": "Bearer $token",
    };
  }

  ///Request Screen API Calls
  Future<RequestDataModel?> getRequestData(
      {int page = 0, int limit = 1000}) async {
    String? employeeId = getJWTModel()?.employeeId;
    if (employeeId == null) return null;

    Map<String, dynamic> requestBody = {
      "requestTypes": [
        "leaveRequest",
        "loanRequest",
        "expenseRequest",
        "allowance_Increment",
        "documentRequest",
        "specialLeaveRequest",
        "attendanceRequest",
        "overTimeRequest",
        "remoteRequest",
        "resignationRequest",
        "complaintRequest"
      ],
    };

    final uri = Uri.parse(
      '$baseURL/request/employee/$employeeId?limit=$limit&page=$page',
    );
    try {
      final response = await http.post(
        uri,
        body: json.encode(requestBody),
        headers: getHeaders(),
      );

      log("Request Log: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        var requestData = RequestDataModel.fromJson(responseBody);

        if (page == 0) {
          setRequestData([requestData]);
        } else {
          final existing = requestDataList;
          setRequestData([...existing, requestData]);
        }
        return requestData;
      } else {
        log("Error request Data: Received status code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log('Error request data: $e');
      return null;
    }
  }

  Future<ApproverRequestData?> getApproverData(
      {int page = 0, int limit = 100}) async {
    final grade = getJWTModel()?.grade;
    final isTargetGrade = ['L0', 'L1', 'L2'].contains(grade);

    if (isTargetGrade && selectedCompanyId != null && branchID != null && selectedCompanyId!.isNotEmpty && branchID!.isNotEmpty) {
      return getRequestByCompanyAndBranch(selectedCompanyId!, branchID!, page: page, limit: limit);
    }

    final uri = Uri.parse(
      '$baseURL/request/approverData?page=$page&limit=$limit',
    );
    try {
      final response = await http.get(
        uri,
        headers: getHeaders(),
      );

      log("Request Log approverData: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        final requestData = ApproverRequestData.fromJson(responseBody);
        if (page == 0) {
          setApproverDataList([requestData]);
        } else {
          final existing = approverDataList;
          setApproverDataList([...existing, requestData]);
        }

        return requestData;
      } else {
        log("Error: Received status code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log('Error Approver Data: $e');
      return null;
    }
  }

  Future<int> fetchTotalApprovedRequestsCount() async {
    try {
      final employeeId = getJWTModel()?.employeeId;
      if (employeeId == null) return totalApprovedRequestsCount;

      final requestBody = {
        "requestTypes": [
          "leaveRequest",
          "loanRequest",
          "expenseRequest",
          "allowance_Increment",
          "documentRequest",
          "specialLeaveRequest",
          "attendanceRequest",
          "overTimeRequest",
          "remoteRequest",
          "resignationRequest",
          "complaintRequest"
        ],
      };

      final uri = Uri.parse(
        '$baseURL/request/employee/$employeeId?limit=1000&page=0',
      );
      final response = await http.post(
        uri,
        body: json.encode(requestBody),
        headers: getHeaders(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final requestData = RequestDataModel.fromJson(responseBody);
        if (requestData.data != null && requestData.data!.data != null) {
          setRequestData([requestData]);
          final count = requestData.data!.data!.where((req) {
            final status = req.status?.toLowerCase();
            return status == 'approved' || status == 'rejected';
          }).length;
          totalApprovedRequestsCount = count;
          return count;
        }
      }
    } catch (e) {
      log('Error counting approved/rejected requests: $e');
    }
    return totalApprovedRequestsCount;
  }

  Future<int> fetchTotalPendingApprovalsCount({bool isTeamChecked = false}) async {
    try {
      final grade = getJWTModel()?.grade;
      final isTargetGrade = ['L0', 'L1', 'L2'].contains(grade);

      ApproverRequestData? data;
      if (isTargetGrade && !isTeamChecked) {
        final companyId = selectedCompanyId;
        final branchId = branchID;
        if (companyId != null && branchId != null && companyId.isNotEmpty && branchId.isNotEmpty) {
          final uri = Uri.parse(
            '$baseURL/request/requestByCompany&BranchId/$companyId/$branchId?page=0&limit=1000',
          );
          final response = await http.get(
            uri,
            headers: getHeaders(),
          );
          if (response.statusCode == 200 || response.statusCode == 201) {
            final responseBody = json.decode(response.body);
            data = ApproverRequestData.fromJson(responseBody);
          }
        }
      }

      if (data == null) {
        final uri = Uri.parse(
          '$baseURL/request/approverData?page=0&limit=1000',
        );
        final response = await http.get(
          uri,
          headers: getHeaders(),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseBody = json.decode(response.body);
          data = ApproverRequestData.fromJson(responseBody);
        }
      }

      if (data != null && data.data != null && data.data!.data != null) {
        setApproverDataList([data]);
        final count = data.data!.data!.where((req) => req.status == 'pending').length;
        totalPendingApprovalsCount = count;
        return count;
      }
    } catch (e) {
      log('Error counting pending approvals: $e');
    }
    return totalPendingApprovalsCount;
  }

  int getCombinedRequestBadgeCount() {
    return totalApprovedRequestsCount + totalPendingApprovalsCount;
  }

  Future<ApproverRequestData?> getRequestByCompanyAndBranch(
      String companyId, String branchId, {int page = 0, int limit = 25}) async {
    final uri = Uri.parse(
      '$baseURL/request/requestByCompany&BranchId/$companyId/$branchId?page=$page&limit=$limit',
    );
    print("🌐 requestByCompanyAndBranch URL: $uri");
    try {
      final response = await http.get(
        uri,
        headers: getHeaders(),
      );

      log("Response requestByCompanyAndBranch: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        final requestData = ApproverRequestData.fromJson(responseBody);

        if (page == 0) {
          setApproverDataList([requestData]);
        } else {
          final existing = approverDataList;
          setApproverDataList([...existing, requestData]);
        }

        return requestData;
      } else {
        log("Error: Received status code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log('Error requestByCompanyAndBranch: $e');
      return null;
    }
  }

  ///Clear all data lists
  void reset() {
    employeeDataList.clear();
    companyNotificationDataList.clear();
    documentSharedTemplateDataList.clear();
    reportManagerDataList.clear();
    roleAndAccessModelDataList.clear();
    biometricDevicesModelDataList.clear();
    organizationModelDataList.clear();
    companiesDataList.clear();
    branchesDataList.clear();
    documentNotificationDataList.clear();
    tenantIDDataList.clear();
    complaintsApproverDataList.clear();
    penaltiesApproverDataList.clear();
    signatureModelList.clear();
    remoteAttendanceModelList.clear();
    projectsDataList.clear();
    taskAttachmentDataList.clear();
    taskModelList.clear();
    projectsLogoModelList.clear();
    penaltiesDataList.clear();
    notificationModelList.clear();
    complaintsDataList.clear();
    profileResponseDataList.clear();
    attachmentResponseDataList.clear();
    searchEmployeeDataList.clear();
    assetsDetailsModel.clear();
    employeeDetailsAssetsModel.clear();
    employeeDetailsAttendanceDataList.clear();
    attendanceDataList.clear();
    teamAttendanceDataList.clear();
    approverDataList.clear();
    companyDataList.clear();
    requestDataList.clear();
    employeeDetailsDataList.clear();
    employeeDetailsClockingDataList.clear();
    checkInDataList.clear();
    clockingDataList.clear();
    teamClockingDataList.clear();
    branchDataList.clear();
    teamBranchDataList.clear();
    eventDataList.clear();
    policyModelDataList.clear();
    uiSettingsModelDataList.clear();
    branchShiftsDataList.clear();
    timeTableShiftsDataList.clear();
    branchesModelDataList.clear();
    companyAssetsDataList.clear();
    companyDetailDocumentNotificationDataList.clear();
    socketDataList.clear();
    slackDataList.clear();
    storeModelDataList.clear();
    availableBranches.clear();
    chatMessages.clear();
    unreadCount = 0;
    _loginModel = null;
    _jwtData = null;
    checkInStatus = null;
    selectedCompanyId = null;
    checkOutStatus = null;
    fcmToken = null;
    companyName = null;
    branchID = null;
    branchName = null;
    activeChatRoomId = null;
    activeScreen = null;
    hasShownGreeting = false;
    isFirstTimeSelectionDone = false;
    local = null;
    headerUrl = '';
    footerUrl = '';
    token = null;
    isTimerActive = false;
  }


  ///POP UPS
  Future<void> showSuccessPopup(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // prevent tap-to-dismiss
      builder: (_) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: SuccessfulPopup(),
        );
      },
    );
  }

  Future<void> showNotSuccessPopup(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // prevent tap-to-dismiss
      builder: (_) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: UnsuccessfulPopup(),
        );
      },
    );
  }

  Future<void> showFaceIDSuccessPopup(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // prevent tap-to-dismiss
      builder: (_) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: FaceIdPopup(),
        );
      },
    );
  }

}


