import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @approvals.
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get approvals;

  /// No description provided for @teamMates.
  ///
  /// In en, this message translates to:
  /// **'Team mates'**
  String get teamMates;

  /// No description provided for @manageTime.
  ///
  /// In en, this message translates to:
  /// **'Manage Time'**
  String get manageTime;

  /// No description provided for @finance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @ksaBranch.
  ///
  /// In en, this message translates to:
  /// **'KSA Branch'**
  String get ksaBranch;

  /// No description provided for @charts.
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get charts;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @requestLeave.
  ///
  /// In en, this message translates to:
  /// **'Request Leave'**
  String get requestLeave;

  /// No description provided for @yourTimeOffBalance.
  ///
  /// In en, this message translates to:
  /// **'Your Time Off Balance'**
  String get yourTimeOffBalance;

  /// No description provided for @balanceAsOfDate.
  ///
  /// In en, this message translates to:
  /// **'Balance As Of Date:'**
  String get balanceAsOfDate;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @todaysClocking.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Clocking'**
  String get todaysClocking;

  /// No description provided for @viewHistory.
  ///
  /// In en, this message translates to:
  /// **'View History'**
  String get viewHistory;

  /// No description provided for @clockIn.
  ///
  /// In en, this message translates to:
  /// **'Clock In'**
  String get clockIn;

  /// No description provided for @todaysHours.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Hours'**
  String get todaysHours;

  /// No description provided for @clockInButton.
  ///
  /// In en, this message translates to:
  /// **'Clock In'**
  String get clockInButton;

  /// No description provided for @annualVacations.
  ///
  /// In en, this message translates to:
  /// **'Annual Vacations'**
  String get annualVacations;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @sickDayOff.
  ///
  /// In en, this message translates to:
  /// **'Sick Day Off'**
  String get sickDayOff;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @myApprovals.
  ///
  /// In en, this message translates to:
  /// **'My Approvals'**
  String get myApprovals;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @mySchedule.
  ///
  /// In en, this message translates to:
  /// **'My Schedule'**
  String get mySchedule;

  /// No description provided for @absentEmployees.
  ///
  /// In en, this message translates to:
  /// **'Absent Employees'**
  String get absentEmployees;

  /// No description provided for @notClockedInYet.
  ///
  /// In en, this message translates to:
  /// **'Not Clocked In Yet'**
  String get notClockedInYet;

  /// No description provided for @whosOnWorkingRemotely.
  ///
  /// In en, this message translates to:
  /// **'Who\'s On Working Remotely'**
  String get whosOnWorkingRemotely;

  /// No description provided for @sixEmployees.
  ///
  /// In en, this message translates to:
  /// **'6 Employees'**
  String get sixEmployees;

  /// No description provided for @workingRemotely.
  ///
  /// In en, this message translates to:
  /// **'Working Remotely'**
  String get workingRemotely;

  /// No description provided for @clockedIn.
  ///
  /// In en, this message translates to:
  /// **'Clocked-In'**
  String get clockedIn;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @companyOuting.
  ///
  /// In en, this message translates to:
  /// **'Company Outing'**
  String get companyOuting;

  /// No description provided for @companyOutingTime.
  ///
  /// In en, this message translates to:
  /// **'03:00 PM - 09:00 AM'**
  String get companyOutingTime;

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add Event'**
  String get addEvent;

  /// No description provided for @viewAllEvents.
  ///
  /// In en, this message translates to:
  /// **'View All Events'**
  String get viewAllEvents;

  /// No description provided for @announcements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcements;

  /// No description provided for @halfToOne.
  ///
  /// In en, this message translates to:
  /// **'2/1'**
  String get halfToOne;

  /// No description provided for @seventyFive.
  ///
  /// In en, this message translates to:
  /// **'75'**
  String get seventyFive;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @dailyStandup.
  ///
  /// In en, this message translates to:
  /// **'Daily Standup'**
  String get dailyStandup;

  /// No description provided for @budgetReview.
  ///
  /// In en, this message translates to:
  /// **'Budget Review'**
  String get budgetReview;

  /// No description provided for @sashaJay121.
  ///
  /// In en, this message translates to:
  /// **'Sasha Jay 121'**
  String get sashaJay121;

  /// No description provided for @webTeamProgressUpdate.
  ///
  /// In en, this message translates to:
  /// **'Web Team Progress Update'**
  String get webTeamProgressUpdate;

  /// No description provided for @socialTeamBriefing.
  ///
  /// In en, this message translates to:
  /// **'Social Team Briefing'**
  String get socialTeamBriefing;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @techStandup.
  ///
  /// In en, this message translates to:
  /// **'Tech Standup'**
  String get techStandup;

  /// No description provided for @developerProgress.
  ///
  /// In en, this message translates to:
  /// **'Developer Progress'**
  String get developerProgress;

  /// No description provided for @vacations.
  ///
  /// In en, this message translates to:
  /// **'Vacations'**
  String get vacations;

  /// No description provided for @bahamas.
  ///
  /// In en, this message translates to:
  /// **'Bahamas'**
  String get bahamas;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'01-02 to 02-14'**
  String get dateRange;

  /// No description provided for @january2022.
  ///
  /// In en, this message translates to:
  /// **'January 2022'**
  String get january2022;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun 💆‍♀️'**
  String get sun;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon 🧟'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue ☕'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed 🐪'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu 🧠'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri 🍸'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat 🎉'**
  String get sat;

  /// No description provided for @day01.
  ///
  /// In en, this message translates to:
  /// **'01'**
  String get day01;

  /// No description provided for @day08.
  ///
  /// In en, this message translates to:
  /// **'08'**
  String get day08;

  /// No description provided for @eventName.
  ///
  /// In en, this message translates to:
  /// **'Event Name'**
  String get eventName;

  /// No description provided for @time0800.
  ///
  /// In en, this message translates to:
  /// **'08:00'**
  String get time0800;

  /// No description provided for @day15.
  ///
  /// In en, this message translates to:
  /// **'15'**
  String get day15;

  /// No description provided for @breaks.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get breaks;

  /// No description provided for @breakOut.
  ///
  /// In en, this message translates to:
  /// **'Break-Out'**
  String get breakOut;

  /// No description provided for @clockOut.
  ///
  /// In en, this message translates to:
  /// **'Clock-Out'**
  String get clockOut;

  /// No description provided for @totalEmployeeSalary.
  ///
  /// In en, this message translates to:
  /// **'Total Employee Salary'**
  String get totalEmployeeSalary;

  /// No description provided for @totalEmployees.
  ///
  /// In en, this message translates to:
  /// **'Total Employees'**
  String get totalEmployees;

  /// No description provided for @fromJune2024ToJuly2024.
  ///
  /// In en, this message translates to:
  /// **'From June, 2024 to July, 2024'**
  String get fromJune2024ToJuly2024;

  /// No description provided for @onLeaves.
  ///
  /// In en, this message translates to:
  /// **'On Leaves'**
  String get onLeaves;

  /// No description provided for @seeDetails.
  ///
  /// In en, this message translates to:
  /// **'See Details'**
  String get seeDetails;

  /// No description provided for @absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// No description provided for @lateComings.
  ///
  /// In en, this message translates to:
  /// **'Late Comings'**
  String get lateComings;

  /// No description provided for @onRemote.
  ///
  /// In en, this message translates to:
  /// **'On Remote'**
  String get onRemote;

  /// No description provided for @selectBranch.
  ///
  /// In en, this message translates to:
  /// **'Select Branch'**
  String get selectBranch;

  /// No description provided for @employees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get employees;

  /// No description provided for @nationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationality;

  /// No description provided for @assets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assets;

  /// No description provided for @salaries.
  ///
  /// In en, this message translates to:
  /// **'Salaries'**
  String get salaries;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @yourTeamRequest.
  ///
  /// In en, this message translates to:
  /// **'Your Team Request'**
  String get yourTeamRequest;

  /// No description provided for @viewApprovals.
  ///
  /// In en, this message translates to:
  /// **'View Approvals'**
  String get viewApprovals;

  /// No description provided for @annualLeaveTwoDays.
  ///
  /// In en, this message translates to:
  /// **'Annual Leave (2 Days)'**
  String get annualLeaveTwoDays;

  /// No description provided for @salaryIncrement.
  ///
  /// In en, this message translates to:
  /// **'Salary Increment'**
  String get salaryIncrement;

  /// No description provided for @insuranceInfo.
  ///
  /// In en, this message translates to:
  /// **'Insurance Info'**
  String get insuranceInfo;

  /// No description provided for @complainsForEmployee.
  ///
  /// In en, this message translates to:
  /// **'Complains for Employee'**
  String get complainsForEmployee;

  /// No description provided for @companyNotifications.
  ///
  /// In en, this message translates to:
  /// **'Company Notifications'**
  String get companyNotifications;

  /// No description provided for @licence.
  ///
  /// In en, this message translates to:
  /// **'Licence'**
  String get licence;

  /// No description provided for @commercialRegistration.
  ///
  /// In en, this message translates to:
  /// **'Commercial Registration'**
  String get commercialRegistration;

  /// No description provided for @vehicles.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get vehicles;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @fourApprovals.
  ///
  /// In en, this message translates to:
  /// **'4 approvals'**
  String get fourApprovals;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @yourApprovals.
  ///
  /// In en, this message translates to:
  /// **'Your Approvals'**
  String get yourApprovals;

  /// No description provided for @annualLeaveThreeDays.
  ///
  /// In en, this message translates to:
  /// **'Annual Leave (3 Days)'**
  String get annualLeaveThreeDays;

  /// No description provided for @complainForEmployee.
  ///
  /// In en, this message translates to:
  /// **'Complain For Employee'**
  String get complainForEmployee;

  /// No description provided for @insuranceInfoDetail.
  ///
  /// In en, this message translates to:
  /// **'Insurance Info'**
  String get insuranceInfoDetail;

  /// No description provided for @salaryIncrementDetail.
  ///
  /// In en, this message translates to:
  /// **'Salary Increment'**
  String get salaryIncrementDetail;

  /// No description provided for @complainForLaptop.
  ///
  /// In en, this message translates to:
  /// **'Complain for Laptop'**
  String get complainForLaptop;

  /// No description provided for @availableDocuments.
  ///
  /// In en, this message translates to:
  /// **'Available Documents'**
  String get availableDocuments;

  /// No description provided for @totalOwnedAssets.
  ///
  /// In en, this message translates to:
  /// **'Total owned assets'**
  String get totalOwnedAssets;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @salaryAndAllowances.
  ///
  /// In en, this message translates to:
  /// **'Salary & Allowances'**
  String get salaryAndAllowances;

  /// No description provided for @orgChart.
  ///
  /// In en, this message translates to:
  /// **'Through this chart, you can easily identify reporting relationships, team members, and department structures. You can also access the detailed profiles for each team member directly from the organizational chart.'**
  String get orgChart;

  /// No description provided for @lets.
  ///
  /// In en, this message translates to:
  /// **'Let\'s'**
  String get lets;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @enterTheEmailAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter the email & password your administrator provided you with'**
  String get enterTheEmailAndPassword;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get userName;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgetPassword.
  ///
  /// In en, this message translates to:
  /// **'Forget password'**
  String get forgetPassword;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get pleaseEnterUsername;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseEnterPassword;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check-In'**
  String get checkIn;

  /// No description provided for @checkOut.
  ///
  /// In en, this message translates to:
  /// **'Check-Out'**
  String get checkOut;

  /// No description provided for @worked.
  ///
  /// In en, this message translates to:
  /// **'Worked'**
  String get worked;

  /// No description provided for @swipeToCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Swipe to Check-In'**
  String get swipeToCheckIn;

  /// No description provided for @loans.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get loans;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @meetings.
  ///
  /// In en, this message translates to:
  /// **'Meetings'**
  String get meetings;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @bankAccounts.
  ///
  /// In en, this message translates to:
  /// **'Bank Accounts'**
  String get bankAccounts;

  /// No description provided for @familyInfo.
  ///
  /// In en, this message translates to:
  /// **'Family Info'**
  String get familyInfo;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @martialStatus.
  ///
  /// In en, this message translates to:
  /// **'Martial Status'**
  String get martialStatus;

  /// No description provided for @phoneNo.
  ///
  /// In en, this message translates to:
  /// **'Phone No'**
  String get phoneNo;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @passportNo.
  ///
  /// In en, this message translates to:
  /// **'Passport No'**
  String get passportNo;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @salary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salary;

  /// No description provided for @fatherName.
  ///
  /// In en, this message translates to:
  /// **'Father Name'**
  String get fatherName;

  /// No description provided for @motherName.
  ///
  /// In en, this message translates to:
  /// **'Mother Name'**
  String get motherName;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @familyPhoneNo.
  ///
  /// In en, this message translates to:
  /// **'Family Phone No'**
  String get familyPhoneNo;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergencyContact;

  /// No description provided for @relation.
  ///
  /// In en, this message translates to:
  /// **'Relation'**
  String get relation;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @biometrics.
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get biometrics;

  /// No description provided for @myClocking.
  ///
  /// In en, this message translates to:
  /// **'My Clocking'**
  String get myClocking;

  /// No description provided for @payroll.
  ///
  /// In en, this message translates to:
  /// **'Payroll'**
  String get payroll;

  /// No description provided for @lastMonthSalary.
  ///
  /// In en, this message translates to:
  /// **'Last Month\'s Salary'**
  String get lastMonthSalary;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @remainingAmount.
  ///
  /// In en, this message translates to:
  /// **'Remaining Amount'**
  String get remainingAmount;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @assignedAssets.
  ///
  /// In en, this message translates to:
  /// **'Assigned Assets'**
  String get assignedAssets;

  /// No description provided for @myDocuments.
  ///
  /// In en, this message translates to:
  /// **'My Documents'**
  String get myDocuments;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login Successful'**
  String get loginSuccess;

  /// No description provided for @complaints.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get complaints;

  /// No description provided for @teamClocking.
  ///
  /// In en, this message translates to:
  /// **'Team Clocking'**
  String get teamClocking;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @checkOutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Check-out Successfully!'**
  String get checkOutSuccess;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to check-out?'**
  String get areYouSure;

  /// No description provided for @pressButtonToCheckOut.
  ///
  /// In en, this message translates to:
  /// **'Press button to check-out'**
  String get pressButtonToCheckOut;

  /// No description provided for @clockInType.
  ///
  /// In en, this message translates to:
  /// **'Select Clock-in Type'**
  String get clockInType;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @biometricCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Biometric Check-in'**
  String get biometricCheckIn;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @teamComplaints.
  ///
  /// In en, this message translates to:
  /// **'Team Complaints'**
  String get teamComplaints;

  /// No description provided for @myComplaints.
  ///
  /// In en, this message translates to:
  /// **'My Complaints'**
  String get myComplaints;

  /// No description provided for @fileComplain.
  ///
  /// In en, this message translates to:
  /// **'File Complain'**
  String get fileComplain;

  /// No description provided for @areYouSureToLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to logout?'**
  String get areYouSureToLogout;

  /// No description provided for @checkInComplete.
  ///
  /// In en, this message translates to:
  /// **'Check-in completed successfully!'**
  String get checkInComplete;

  /// No description provided for @checkOutComplete.
  ///
  /// In en, this message translates to:
  /// **'Check-out completed successfully!'**
  String get checkOutComplete;

  /// No description provided for @internalServerError.
  ///
  /// In en, this message translates to:
  /// **'Internal server error!'**
  String get internalServerError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get tryAgain;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @employeeProfile.
  ///
  /// In en, this message translates to:
  /// **'Employee Profile'**
  String get employeeProfile;

  /// No description provided for @annualLeave.
  ///
  /// In en, this message translates to:
  /// **'Annual Leave'**
  String get annualLeave;

  /// No description provided for @sickLeave.
  ///
  /// In en, this message translates to:
  /// **'Sick Leave'**
  String get sickLeave;

  /// No description provided for @leaveHistory.
  ///
  /// In en, this message translates to:
  /// **'Leave History'**
  String get leaveHistory;

  /// No description provided for @errorFetchData.
  ///
  /// In en, this message translates to:
  /// **'Error fetching data. Please try again later'**
  String get errorFetchData;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @leaveRemaining.
  ///
  /// In en, this message translates to:
  /// **'Leave Remaining'**
  String get leaveRemaining;

  /// No description provided for @leaveUsed.
  ///
  /// In en, this message translates to:
  /// **'Leave Used'**
  String get leaveUsed;

  /// No description provided for @late.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get late;

  /// No description provided for @earlyCheckOut.
  ///
  /// In en, this message translates to:
  /// **'Early check-out'**
  String get earlyCheckOut;

  /// No description provided for @earlyLeft.
  ///
  /// In en, this message translates to:
  /// **'Early Left'**
  String get earlyLeft;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Add Comment'**
  String get comment;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @acceptRequest.
  ///
  /// In en, this message translates to:
  /// **'Accept Request'**
  String get acceptRequest;

  /// No description provided for @rejectRequest.
  ///
  /// In en, this message translates to:
  /// **'Reject Request'**
  String get rejectRequest;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @complainDetails.
  ///
  /// In en, this message translates to:
  /// **'Complain Details'**
  String get complainDetails;

  /// No description provided for @payrollMonth.
  ///
  /// In en, this message translates to:
  /// **'Payroll Month'**
  String get payrollMonth;

  /// No description provided for @employeeSalary.
  ///
  /// In en, this message translates to:
  /// **'Employee Salary'**
  String get employeeSalary;

  /// No description provided for @loansDetails.
  ///
  /// In en, this message translates to:
  /// **'Loans Details'**
  String get loansDetails;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @pendingRequest.
  ///
  /// In en, this message translates to:
  /// **'Pending Request'**
  String get pendingRequest;

  /// No description provided for @requestDate.
  ///
  /// In en, this message translates to:
  /// **'Request Date'**
  String get requestDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No Pending Requests'**
  String get noPendingRequests;

  /// No description provided for @noUpcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'No Upcoming Events'**
  String get noUpcomingEvents;

  /// No description provided for @attendanceCalendar.
  ///
  /// In en, this message translates to:
  /// **'Attendance Calendar'**
  String get attendanceCalendar;

  /// No description provided for @userProfile.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfile;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @editSuccess.
  ///
  /// In en, this message translates to:
  /// **'Edit successfully!'**
  String get editSuccess;

  /// No description provided for @successUpdate.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get successUpdate;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get fileName;

  /// No description provided for @uploadDocument.
  ///
  /// In en, this message translates to:
  /// **'Upload Document'**
  String get uploadDocument;

  /// No description provided for @viewDocument.
  ///
  /// In en, this message translates to:
  /// **'View Document'**
  String get viewDocument;

  /// No description provided for @fileSize.
  ///
  /// In en, this message translates to:
  /// **'File Size'**
  String get fileSize;

  /// No description provided for @fileType.
  ///
  /// In en, this message translates to:
  /// **'File Type'**
  String get fileType;

  /// No description provided for @documentUploaded.
  ///
  /// In en, this message translates to:
  /// **'Document Uploaded'**
  String get documentUploaded;

  /// No description provided for @yourLeaves.
  ///
  /// In en, this message translates to:
  /// **'Your Leaves'**
  String get yourLeaves;

  /// No description provided for @unapproved.
  ///
  /// In en, this message translates to:
  /// **'Unapproved'**
  String get unapproved;

  /// No description provided for @approvedLeaves.
  ///
  /// In en, this message translates to:
  /// **'Approved Leaves'**
  String get approvedLeaves;

  /// No description provided for @leaveCount.
  ///
  /// In en, this message translates to:
  /// **'Leave Count'**
  String get leaveCount;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @leaveRequests.
  ///
  /// In en, this message translates to:
  /// **'Leave Requests'**
  String get leaveRequests;

  /// No description provided for @leaveTaken.
  ///
  /// In en, this message translates to:
  /// **'Leave Taken'**
  String get leaveTaken;

  /// No description provided for @upcomingLeaves.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Leaves'**
  String get upcomingLeaves;

  /// No description provided for @previousLeaves.
  ///
  /// In en, this message translates to:
  /// **'Previous Leaves'**
  String get previousLeaves;

  /// No description provided for @employeeDetails.
  ///
  /// In en, this message translates to:
  /// **'Employee Details'**
  String get employeeDetails;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @contract.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get contract;

  /// No description provided for @manager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get manager;

  /// No description provided for @approval.
  ///
  /// In en, this message translates to:
  /// **'Approval'**
  String get approval;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @absentCount.
  ///
  /// In en, this message translates to:
  /// **'Absent Count'**
  String get absentCount;

  /// No description provided for @salaryBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Salary Breakdown'**
  String get salaryBreakdown;

  /// No description provided for @approvedLoans.
  ///
  /// In en, this message translates to:
  /// **'Approved Loans'**
  String get approvedLoans;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @loanAmount.
  ///
  /// In en, this message translates to:
  /// **'Loan Amount'**
  String get loanAmount;

  /// No description provided for @reasonForLoan.
  ///
  /// In en, this message translates to:
  /// **'Reason for Loan'**
  String get reasonForLoan;

  /// No description provided for @loanStatus.
  ///
  /// In en, this message translates to:
  /// **'Loan Status'**
  String get loanStatus;

  /// No description provided for @loanDetails.
  ///
  /// In en, this message translates to:
  /// **'Loan Details'**
  String get loanDetails;

  /// No description provided for @bankAccount.
  ///
  /// In en, this message translates to:
  /// **'Bank Account'**
  String get bankAccount;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumber;

  /// No description provided for @accountHolderName.
  ///
  /// In en, this message translates to:
  /// **'Account Holder Name'**
  String get accountHolderName;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bankName;

  /// No description provided for @loanInfo.
  ///
  /// In en, this message translates to:
  /// **'Loan Info'**
  String get loanInfo;

  /// No description provided for @statusInfo.
  ///
  /// In en, this message translates to:
  /// **'Status Info'**
  String get statusInfo;

  /// No description provided for @userRole.
  ///
  /// In en, this message translates to:
  /// **'User Role'**
  String get userRole;

  /// No description provided for @employee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get employee;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @superAdmin.
  ///
  /// In en, this message translates to:
  /// **'Super Admin'**
  String get superAdmin;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @feedbackSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Feedback Submitted'**
  String get feedbackSubmitted;

  /// No description provided for @feedbackError.
  ///
  /// In en, this message translates to:
  /// **'Feedback Error'**
  String get feedbackError;

  /// No description provided for @leaveType.
  ///
  /// In en, this message translates to:
  /// **'Leave Type'**
  String get leaveType;

  /// No description provided for @noticePeriod.
  ///
  /// In en, this message translates to:
  /// **'Notice Period'**
  String get noticePeriod;

  /// No description provided for @lateCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Late Check-In'**
  String get lateCheckIn;

  /// No description provided for @workFromHome.
  ///
  /// In en, this message translates to:
  /// **'Work From Home'**
  String get workFromHome;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @currentLeave.
  ///
  /// In en, this message translates to:
  /// **'Current Leave'**
  String get currentLeave;

  /// No description provided for @totalDays.
  ///
  /// In en, this message translates to:
  /// **'Total Days'**
  String get totalDays;

  /// No description provided for @unapprovedLeaves.
  ///
  /// In en, this message translates to:
  /// **'Unapproved Leaves'**
  String get unapprovedLeaves;

  /// No description provided for @employeesCount.
  ///
  /// In en, this message translates to:
  /// **'Employees Count'**
  String get employeesCount;

  /// No description provided for @maxAllowedDays.
  ///
  /// In en, this message translates to:
  /// **'Max Allowed Days'**
  String get maxAllowedDays;

  /// No description provided for @holiday.
  ///
  /// In en, this message translates to:
  /// **'Holiday'**
  String get holiday;

  /// No description provided for @unpaidLeave.
  ///
  /// In en, this message translates to:
  /// **'Unpaid Leave'**
  String get unpaidLeave;

  /// No description provided for @leaveDays.
  ///
  /// In en, this message translates to:
  /// **'Leave Days'**
  String get leaveDays;

  /// No description provided for @weeklyLeave.
  ///
  /// In en, this message translates to:
  /// **'Weekly Leave'**
  String get weeklyLeave;

  /// No description provided for @workingHours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get workingHours;

  /// No description provided for @maritalStatus.
  ///
  /// In en, this message translates to:
  /// **'Marital Status'**
  String get maritalStatus;

  /// No description provided for @document.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get document;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @issueDate.
  ///
  /// In en, this message translates to:
  /// **'Issue Date'**
  String get issueDate;

  /// No description provided for @expiration.
  ///
  /// In en, this message translates to:
  /// **'Expiration'**
  String get expiration;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile Updated'**
  String get profileUpdated;

  /// No description provided for @profileInfo.
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get profileInfo;

  /// No description provided for @dataSaved.
  ///
  /// In en, this message translates to:
  /// **'Data Saved'**
  String get dataSaved;

  /// No description provided for @documentName.
  ///
  /// In en, this message translates to:
  /// **'Document Name'**
  String get documentName;

  /// No description provided for @attachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get attachment;

  /// No description provided for @documentUploadError.
  ///
  /// In en, this message translates to:
  /// **'Error uploading document. Please try again.'**
  String get documentUploadError;

  /// No description provided for @loan.
  ///
  /// In en, this message translates to:
  /// **'Loan'**
  String get loan;

  /// No description provided for @salaryDetails.
  ///
  /// In en, this message translates to:
  /// **'Salary Details'**
  String get salaryDetails;

  /// No description provided for @netSalary.
  ///
  /// In en, this message translates to:
  /// **'Net Salary'**
  String get netSalary;

  /// No description provided for @grossSalary.
  ///
  /// In en, this message translates to:
  /// **'Gross Salary'**
  String get grossSalary;

  /// No description provided for @insurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get insurance;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @deductions.
  ///
  /// In en, this message translates to:
  /// **'Deductions'**
  String get deductions;

  /// No description provided for @salaryStructure.
  ///
  /// In en, this message translates to:
  /// **'Salary Structure'**
  String get salaryStructure;

  /// No description provided for @payslip.
  ///
  /// In en, this message translates to:
  /// **'Payslip'**
  String get payslip;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @attendanceSummary.
  ///
  /// In en, this message translates to:
  /// **'Attendance Summary'**
  String get attendanceSummary;

  /// No description provided for @totalHours.
  ///
  /// In en, this message translates to:
  /// **'Total Hours'**
  String get totalHours;

  /// No description provided for @leaveDuration.
  ///
  /// In en, this message translates to:
  /// **'Leave Duration'**
  String get leaveDuration;

  /// No description provided for @empLeaveBalance.
  ///
  /// In en, this message translates to:
  /// **'Employee Leave Balance'**
  String get empLeaveBalance;

  /// No description provided for @reporting.
  ///
  /// In en, this message translates to:
  /// **'Reporting'**
  String get reporting;

  /// No description provided for @lateArrival.
  ///
  /// In en, this message translates to:
  /// **'Late Arrival'**
  String get lateArrival;

  /// No description provided for @presentCount.
  ///
  /// In en, this message translates to:
  /// **'Present Count'**
  String get presentCount;

  /// No description provided for @publicHolidays.
  ///
  /// In en, this message translates to:
  /// **'Public Holidays'**
  String get publicHolidays;

  /// No description provided for @leaveSummary.
  ///
  /// In en, this message translates to:
  /// **'Leave Summary'**
  String get leaveSummary;

  /// No description provided for @salaryReport.
  ///
  /// In en, this message translates to:
  /// **'Salary Report'**
  String get salaryReport;

  /// No description provided for @employeeCount.
  ///
  /// In en, this message translates to:
  /// **'Employee Count'**
  String get employeeCount;

  /// No description provided for @leavePending.
  ///
  /// In en, this message translates to:
  /// **'Leave Pending'**
  String get leavePending;

  /// No description provided for @leaveRejected.
  ///
  /// In en, this message translates to:
  /// **'Leave Rejected'**
  String get leaveRejected;

  /// No description provided for @leaveApproved.
  ///
  /// In en, this message translates to:
  /// **'Leave Approved'**
  String get leaveApproved;

  /// No description provided for @holidays.
  ///
  /// In en, this message translates to:
  /// **'Holidays'**
  String get holidays;

  /// No description provided for @myLoans.
  ///
  /// In en, this message translates to:
  /// **'My Loans'**
  String get myLoans;

  /// No description provided for @loanRequest.
  ///
  /// In en, this message translates to:
  /// **'Loan Request'**
  String get loanRequest;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @payrollSummary.
  ///
  /// In en, this message translates to:
  /// **'Payroll Summary'**
  String get payrollSummary;

  /// No description provided for @totalLeaves.
  ///
  /// In en, this message translates to:
  /// **'Total Leaves'**
  String get totalLeaves;

  /// No description provided for @holidayCount.
  ///
  /// In en, this message translates to:
  /// **'Holiday Count'**
  String get holidayCount;

  /// No description provided for @leaveReport.
  ///
  /// In en, this message translates to:
  /// **'Leave Report'**
  String get leaveReport;

  /// No description provided for @holidaySummary.
  ///
  /// In en, this message translates to:
  /// **'Holiday Summary'**
  String get holidaySummary;

  /// No description provided for @loanRequests.
  ///
  /// In en, this message translates to:
  /// **'Loan Requests'**
  String get loanRequests;

  /// No description provided for @activeLoans.
  ///
  /// In en, this message translates to:
  /// **'Active Loans'**
  String get activeLoans;

  /// No description provided for @rejectedLoans.
  ///
  /// In en, this message translates to:
  /// **'Rejected Loans'**
  String get rejectedLoans;

  /// No description provided for @loanHistory.
  ///
  /// In en, this message translates to:
  /// **'Loan History'**
  String get loanHistory;

  /// No description provided for @repaymentDate.
  ///
  /// In en, this message translates to:
  /// **'Repayment Date'**
  String get repaymentDate;

  /// No description provided for @repaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Repayment Status'**
  String get repaymentStatus;

  /// No description provided for @loanSummary.
  ///
  /// In en, this message translates to:
  /// **'Loan Summary'**
  String get loanSummary;

  /// No description provided for @attendances.
  ///
  /// In en, this message translates to:
  /// **'Attendances'**
  String get attendances;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @overTime.
  ///
  /// In en, this message translates to:
  /// **'Overtime'**
  String get overTime;

  /// No description provided for @training.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get training;

  /// No description provided for @selectRequestType.
  ///
  /// In en, this message translates to:
  /// **'Select a Request Type'**
  String get selectRequestType;

  /// No description provided for @passwordOrPhoneNo.
  ///
  /// In en, this message translates to:
  /// **'Password or Phone number is incorrect'**
  String get passwordOrPhoneNo;

  /// No description provided for @pleaseEnterNotes.
  ///
  /// In en, this message translates to:
  /// **'Please enter a note'**
  String get pleaseEnterNotes;

  /// No description provided for @enterToAndFromDate.
  ///
  /// In en, this message translates to:
  /// **'Please select both From Date and To Date'**
  String get enterToAndFromDate;

  /// No description provided for @selectSubType.
  ///
  /// In en, this message translates to:
  /// **'select SubType'**
  String get selectSubType;

  /// No description provided for @penalties.
  ///
  /// In en, this message translates to:
  /// **'Penalties'**
  String get penalties;

  /// No description provided for @penaltiesAndFine.
  ///
  /// In en, this message translates to:
  /// **'Penalties & Fine'**
  String get penaltiesAndFine;

  /// No description provided for @penaltiesAndFineBottom.
  ///
  /// In en, this message translates to:
  /// **'Penalties & Fine Type'**
  String get penaltiesAndFineBottom;

  /// No description provided for @againstMe.
  ///
  /// In en, this message translates to:
  /// **'Against me'**
  String get againstMe;

  /// No description provided for @teams.
  ///
  /// In en, this message translates to:
  /// **'Team\'s'**
  String get teams;

  /// No description provided for @applyRequests.
  ///
  /// In en, this message translates to:
  /// **'Apply Request'**
  String get applyRequests;

  /// No description provided for @subType.
  ///
  /// In en, this message translates to:
  /// **'subType'**
  String get subType;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To date'**
  String get toDate;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From date'**
  String get fromDate;

  /// No description provided for @attachDocuments.
  ///
  /// In en, this message translates to:
  /// **'Attach Documents'**
  String get attachDocuments;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @totalLoanAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Loan Amount'**
  String get totalLoanAmount;

  /// No description provided for @installmentAmount.
  ///
  /// In en, this message translates to:
  /// **'Installment Amount'**
  String get installmentAmount;

  /// No description provided for @searchEmployee.
  ///
  /// In en, this message translates to:
  /// **'Search Employee'**
  String get searchEmployee;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @selectSeverityOfEmployee.
  ///
  /// In en, this message translates to:
  /// **'Select Severity of employee'**
  String get selectSeverityOfEmployee;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @insufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Leave Balance'**
  String get insufficientBalance;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @employeeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Employee not found'**
  String get employeeNotFound;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @pleaseAttachDocument.
  ///
  /// In en, this message translates to:
  /// **'Please Attach Documents!'**
  String get pleaseAttachDocument;

  /// No description provided for @youHaveNotCheckedInYet.
  ///
  /// In en, this message translates to:
  /// **'You have not checked in yet. Please check in first.'**
  String get youHaveNotCheckedInYet;

  /// No description provided for @currentLocationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Current location not available.'**
  String get currentLocationNotAvailable;

  /// No description provided for @sorryYouAreOutOfTheLocationRadius.
  ///
  /// In en, this message translates to:
  /// **'Sorry, you are out of the location radius!'**
  String get sorryYouAreOutOfTheLocationRadius;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @maximum300.
  ///
  /// In en, this message translates to:
  /// **'Maximum 300 characters limit. Special characters are not allowed.'**
  String get maximum300;

  /// No description provided for @typeYourComplainHere.
  ///
  /// In en, this message translates to:
  /// **'Type your complain here..'**
  String get typeYourComplainHere;

  /// No description provided for @typeYourTitleHere.
  ///
  /// In en, this message translates to:
  /// **'Type your title here..'**
  String get typeYourTitleHere;

  /// No description provided for @confirmUpload.
  ///
  /// In en, this message translates to:
  /// **'Confirm Upload'**
  String get confirmUpload;

  /// No description provided for @areYouSureYouWantToUploadThisFile.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to upload this file:'**
  String get areYouSureYouWantToUploadThisFile;

  /// No description provided for @balanceToDate.
  ///
  /// In en, this message translates to:
  /// **'Balance to Date'**
  String get balanceToDate;

  /// No description provided for @balanceToEndOfYear.
  ///
  /// In en, this message translates to:
  /// **'Balance to end of year'**
  String get balanceToEndOfYear;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @loanInstallment.
  ///
  /// In en, this message translates to:
  /// **'Loan Installment'**
  String get loanInstallment;

  /// No description provided for @loanCycle.
  ///
  /// In en, this message translates to:
  /// **'Loan Cycle'**
  String get loanCycle;

  /// No description provided for @out.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get out;

  /// No description provided for @breakTaken.
  ///
  /// In en, this message translates to:
  /// **'Breaks Taken'**
  String get breakTaken;

  /// No description provided for @breakNo.
  ///
  /// In en, this message translates to:
  /// **'Break no'**
  String get breakNo;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @totalDuration.
  ///
  /// In en, this message translates to:
  /// **'Total Duration'**
  String get totalDuration;

  /// No description provided for @leaveInfo.
  ///
  /// In en, this message translates to:
  /// **'Leave Information'**
  String get leaveInfo;

  /// No description provided for @remarks.
  ///
  /// In en, this message translates to:
  /// **'Remarks'**
  String get remarks;

  /// No description provided for @shiftInfo.
  ///
  /// In en, this message translates to:
  /// **'Shift Info'**
  String get shiftInfo;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get jobTitle;

  /// No description provided for @jobDescription.
  ///
  /// In en, this message translates to:
  /// **'Job Description'**
  String get jobDescription;

  /// No description provided for @reportingManager.
  ///
  /// In en, this message translates to:
  /// **'Reporting Manager'**
  String get reportingManager;

  /// No description provided for @employeeShift.
  ///
  /// In en, this message translates to:
  /// **'Employee Shift'**
  String get employeeShift;

  /// No description provided for @createAnIssue.
  ///
  /// In en, this message translates to:
  /// **'Create an issue'**
  String get createAnIssue;

  /// No description provided for @tdo.
  ///
  /// In en, this message translates to:
  /// **'To Do'**
  String get tdo;

  /// No description provided for @tag.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tag;

  /// No description provided for @assignee.
  ///
  /// In en, this message translates to:
  /// **'Assignee'**
  String get assignee;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @selectStatus.
  ///
  /// In en, this message translates to:
  /// **'Select Status'**
  String get selectStatus;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @selectAssignee.
  ///
  /// In en, this message translates to:
  /// **'Select Assignee'**
  String get selectAssignee;

  /// No description provided for @selectType.
  ///
  /// In en, this message translates to:
  /// **'Select Type'**
  String get selectType;

  /// No description provided for @selectDuration.
  ///
  /// In en, this message translates to:
  /// **'Select Duration'**
  String get selectDuration;

  /// No description provided for @addAttachments.
  ///
  /// In en, this message translates to:
  /// **'Add Attachments'**
  String get addAttachments;

  /// No description provided for @typeYourSubject.
  ///
  /// In en, this message translates to:
  /// **'Type your subject here!'**
  String get typeYourSubject;

  /// No description provided for @typeYourDescription.
  ///
  /// In en, this message translates to:
  /// **'Type your description here!'**
  String get typeYourDescription;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @createAProject.
  ///
  /// In en, this message translates to:
  /// **'Create a project'**
  String get createAProject;

  /// No description provided for @projectName.
  ///
  /// In en, this message translates to:
  /// **'Project name'**
  String get projectName;

  /// No description provided for @projectKey.
  ///
  /// In en, this message translates to:
  /// **'Project Key'**
  String get projectKey;

  /// No description provided for @teamName.
  ///
  /// In en, this message translates to:
  /// **'Team Name'**
  String get teamName;

  /// No description provided for @logo.
  ///
  /// In en, this message translates to:
  /// **'Logo'**
  String get logo;

  /// No description provided for @addLogo.
  ///
  /// In en, this message translates to:
  /// **'Add Logo'**
  String get addLogo;

  /// No description provided for @typeYourProjectNameHere.
  ///
  /// In en, this message translates to:
  /// **'Type your project name here'**
  String get typeYourProjectNameHere;

  /// No description provided for @typeYourProjectDescriptionHere.
  ///
  /// In en, this message translates to:
  /// **'Type your project description here'**
  String get typeYourProjectDescriptionHere;

  /// No description provided for @typeYourProjectKeyHere.
  ///
  /// In en, this message translates to:
  /// **'Type your project key here'**
  String get typeYourProjectKeyHere;

  /// No description provided for @typeYourTeamNameHere.
  ///
  /// In en, this message translates to:
  /// **'Type your team name here'**
  String get typeYourTeamNameHere;

  /// No description provided for @project.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get project;

  /// No description provided for @myTeams.
  ///
  /// In en, this message translates to:
  /// **'My Team'**
  String get myTeams;

  /// No description provided for @requestAndApproval.
  ///
  /// In en, this message translates to:
  /// **'Request & Approvals'**
  String get requestAndApproval;

  /// No description provided for @teamAttendance.
  ///
  /// In en, this message translates to:
  /// **'Team\'s Attendance'**
  String get teamAttendance;

  /// No description provided for @complaintRequest.
  ///
  /// In en, this message translates to:
  /// **'Complaint Request'**
  String get complaintRequest;

  /// No description provided for @allowanceIncrement.
  ///
  /// In en, this message translates to:
  /// **'Allowance Increment'**
  String get allowanceIncrement;

  /// No description provided for @allowanceIncrementBottom.
  ///
  /// In en, this message translates to:
  /// **'Allowance Increment Type'**
  String get allowanceIncrementBottom;

  /// No description provided for @documentRequest.
  ///
  /// In en, this message translates to:
  /// **'Document Request'**
  String get documentRequest;

  /// No description provided for @expenseRequest.
  ///
  /// In en, this message translates to:
  /// **'Expense Request'**
  String get expenseRequest;

  /// No description provided for @casualLeave.
  ///
  /// In en, this message translates to:
  /// **'Casual Leave'**
  String get casualLeave;

  /// No description provided for @advanceSalaryRequest.
  ///
  /// In en, this message translates to:
  /// **'Advance Salary Request'**
  String get advanceSalaryRequest;

  /// No description provided for @longTermLoanRequest.
  ///
  /// In en, this message translates to:
  /// **'Long Term Loan Request'**
  String get longTermLoanRequest;

  /// No description provided for @housingAllowance.
  ///
  /// In en, this message translates to:
  /// **'Housing Allowance'**
  String get housingAllowance;

  /// No description provided for @travellingAllowance.
  ///
  /// In en, this message translates to:
  /// **'Travelling Allowance'**
  String get travellingAllowance;

  /// No description provided for @salaryIncrementalAllowance.
  ///
  /// In en, this message translates to:
  /// **'Salary Incremental Allowance'**
  String get salaryIncrementalAllowance;

  /// No description provided for @salarySlip.
  ///
  /// In en, this message translates to:
  /// **'Salary Slip'**
  String get salarySlip;

  /// No description provided for @promotionalLetter.
  ///
  /// In en, this message translates to:
  /// **'Promotional Letter'**
  String get promotionalLetter;

  /// No description provided for @idCard.
  ///
  /// In en, this message translates to:
  /// **'ID Card'**
  String get idCard;

  /// No description provided for @advance.
  ///
  /// In en, this message translates to:
  /// **'Advance'**
  String get advance;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @reimbursement.
  ///
  /// In en, this message translates to:
  /// **'Reimbursement'**
  String get reimbursement;

  /// No description provided for @disbursement.
  ///
  /// In en, this message translates to:
  /// **'Disbursement'**
  String get disbursement;

  /// No description provided for @star.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get star;

  /// No description provided for @moon.
  ///
  /// In en, this message translates to:
  /// **'Moon'**
  String get moon;

  /// No description provided for @badBehaviour.
  ///
  /// In en, this message translates to:
  /// **'Bad Behaviour'**
  String get badBehaviour;

  /// No description provided for @yourSelf.
  ///
  /// In en, this message translates to:
  /// **'Yourself'**
  String get yourSelf;

  /// No description provided for @createAEvent.
  ///
  /// In en, this message translates to:
  /// **'Create an Event'**
  String get createAEvent;

  /// No description provided for @typeEventNameHere.
  ///
  /// In en, this message translates to:
  /// **'Type event name here'**
  String get typeEventNameHere;

  /// No description provided for @eventDescription.
  ///
  /// In en, this message translates to:
  /// **'Event Description'**
  String get eventDescription;

  /// No description provided for @typeEventDescriptionHere.
  ///
  /// In en, this message translates to:
  /// **'Type event description here'**
  String get typeEventDescriptionHere;

  /// No description provided for @eventCategory.
  ///
  /// In en, this message translates to:
  /// **'Event Category'**
  String get eventCategory;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @eventType.
  ///
  /// In en, this message translates to:
  /// **'Event Type'**
  String get eventType;

  /// No description provided for @typeEventTypeOrSelectFromList.
  ///
  /// In en, this message translates to:
  /// **'Type event type or select from the list'**
  String get typeEventTypeOrSelectFromList;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Mins'**
  String get minutes;

  /// No description provided for @quarterly.
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get quarterly;

  /// No description provided for @missingCheckInOut.
  ///
  /// In en, this message translates to:
  /// **'Missing Check-In/Out'**
  String get missingCheckInOut;

  /// No description provided for @advanceExpense.
  ///
  /// In en, this message translates to:
  /// **'Advance Expense'**
  String get advanceExpense;

  /// No description provided for @businessExpense.
  ///
  /// In en, this message translates to:
  /// **'Business Expense'**
  String get businessExpense;

  /// No description provided for @leaveRequestBottom.
  ///
  /// In en, this message translates to:
  /// **'Leave Type'**
  String get leaveRequestBottom;

  /// No description provided for @loanRequestBottom.
  ///
  /// In en, this message translates to:
  /// **'Loan Type'**
  String get loanRequestBottom;

  /// No description provided for @documentRequestBottom.
  ///
  /// In en, this message translates to:
  /// **'Document Type'**
  String get documentRequestBottom;

  /// No description provided for @expenseRequestBottom.
  ///
  /// In en, this message translates to:
  /// **'Expense Type'**
  String get expenseRequestBottom;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload Failed'**
  String get uploadFailed;

  /// No description provided for @signature.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get signature;

  /// No description provided for @selectComplaintType.
  ///
  /// In en, this message translates to:
  /// **'Select Complaint Type'**
  String get selectComplaintType;

  /// No description provided for @complaintAgainstColleague.
  ///
  /// In en, this message translates to:
  /// **'Complaint Against Colleague'**
  String get complaintAgainstColleague;

  /// No description provided for @complaintAgainstSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Complaint Against Supervisor'**
  String get complaintAgainstSupervisor;

  /// No description provided for @generalComplaint.
  ///
  /// In en, this message translates to:
  /// **'General Complaint'**
  String get generalComplaint;

  /// No description provided for @createLetter.
  ///
  /// In en, this message translates to:
  /// **'Create Letter'**
  String get createLetter;

  /// No description provided for @enterLetterSubjectHere.
  ///
  /// In en, this message translates to:
  /// **'Enter letter subject here...!'**
  String get enterLetterSubjectHere;

  /// No description provided for @enterLetterBodyHere.
  ///
  /// In en, this message translates to:
  /// **'Enter letter body here...!'**
  String get enterLetterBodyHere;

  /// No description provided for @previewLetter.
  ///
  /// In en, this message translates to:
  /// **'Preview Letter'**
  String get previewLetter;

  /// No description provided for @pleaseEnterLetterBody.
  ///
  /// In en, this message translates to:
  /// **'Please enter letter body'**
  String get pleaseEnterLetterBody;

  /// No description provided for @pleaseEnterLetterSubject.
  ///
  /// In en, this message translates to:
  /// **'Please enter letter subject'**
  String get pleaseEnterLetterSubject;

  /// No description provided for @letterBody.
  ///
  /// In en, this message translates to:
  /// **'Letter body'**
  String get letterBody;

  /// No description provided for @onTime.
  ///
  /// In en, this message translates to:
  /// **'On Time'**
  String get onTime;

  /// No description provided for @nassMudeer.
  ///
  /// In en, this message translates to:
  /// **'Nass Mudeer'**
  String get nassMudeer;

  /// No description provided for @leaveThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Leave this month'**
  String get leaveThisMonth;

  /// No description provided for @remoteDaysThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Remote Days this month'**
  String get remoteDaysThisMonth;

  /// No description provided for @sickDaysThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Sick Days this month'**
  String get sickDaysThisMonth;

  /// No description provided for @hey.
  ///
  /// In en, this message translates to:
  /// **'Hey'**
  String get hey;

  /// No description provided for @whatsOnYourMindToday.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind today?'**
  String get whatsOnYourMindToday;

  /// No description provided for @tellMeAboutDocuments.
  ///
  /// In en, this message translates to:
  /// **'Tell me about documents'**
  String get tellMeAboutDocuments;

  /// No description provided for @showMyInfo.
  ///
  /// In en, this message translates to:
  /// **'Show my info'**
  String get showMyInfo;

  /// No description provided for @leaveBalance.
  ///
  /// In en, this message translates to:
  /// **'Leave balance'**
  String get leaveBalance;

  /// No description provided for @myDepartment.
  ///
  /// In en, this message translates to:
  /// **'My department'**
  String get myDepartment;

  /// No description provided for @whoIsDeveloper.
  ///
  /// In en, this message translates to:
  /// **'who is the developer'**
  String get whoIsDeveloper;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get card;

  /// No description provided for @cnic.
  ///
  /// In en, this message translates to:
  /// **'CNIC'**
  String get cnic;

  /// No description provided for @iqama.
  ///
  /// In en, this message translates to:
  /// **'Iqama'**
  String get iqama;

  /// No description provided for @passport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get passport;

  /// No description provided for @employmentContract.
  ///
  /// In en, this message translates to:
  /// **'Employment Contract'**
  String get employmentContract;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @dateOfBirthInHijri.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth in Hijri'**
  String get dateOfBirthInHijri;

  /// No description provided for @expiryDateInHijri.
  ///
  /// In en, this message translates to:
  /// **'Expiry date in Hijri'**
  String get expiryDateInHijri;

  /// No description provided for @placeOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Place of birth'**
  String get placeOfBirth;

  /// No description provided for @contractId.
  ///
  /// In en, this message translates to:
  /// **'Contract ID'**
  String get contractId;

  /// No description provided for @employeeNumber.
  ///
  /// In en, this message translates to:
  /// **'Employee Number'**
  String get employeeNumber;

  /// No description provided for @contractStatus.
  ///
  /// In en, this message translates to:
  /// **'Contract Status'**
  String get contractStatus;

  /// No description provided for @idNumber.
  ///
  /// In en, this message translates to:
  /// **'ID Number'**
  String get idNumber;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @occupation.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get occupation;

  /// No description provided for @religion.
  ///
  /// In en, this message translates to:
  /// **'Religion'**
  String get religion;

  /// No description provided for @missingCheckInAndCheckOut.
  ///
  /// In en, this message translates to:
  /// **'Check-out time is missing Auto updated by system'**
  String get missingCheckInAndCheckOut;

  /// No description provided for @allBranch.
  ///
  /// In en, this message translates to:
  /// **'All Branches'**
  String get allBranch;

  /// No description provided for @attendanceDetail.
  ///
  /// In en, this message translates to:
  /// **'Attendance Detail'**
  String get attendanceDetail;

  /// No description provided for @attendanceHistory.
  ///
  /// In en, this message translates to:
  /// **'Attendance History'**
  String get attendanceHistory;

  /// No description provided for @onlyMe.
  ///
  /// In en, this message translates to:
  /// **'Only me'**
  String get onlyMe;

  /// No description provided for @assetsDetails.
  ///
  /// In en, this message translates to:
  /// **'Asset Detail'**
  String get assetsDetails;

  /// No description provided for @documentNotification.
  ///
  /// In en, this message translates to:
  /// **'Document Notification'**
  String get documentNotification;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
