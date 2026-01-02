import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nashr/screens/main_screen.dart';
import 'package:nashr/screens/pdf_viewer_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:nashr/widgets/loader.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../request_controller/approver_request_data_model.dart';
import 'package:flutter/foundation.dart';
import 'package:printing/printing.dart';

class RequestDetailScreen extends StatefulWidget {
  final DataApprover dataApprover;

  const RequestDetailScreen({super.key, required this.dataApprover});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  SingletonClass singletonClass = SingletonClass();
  bool isLoading = false;
  final TextEditingController _comment = TextEditingController();


  @override
  Widget build(BuildContext context) {
    final allApproved = widget.dataApprover.approvers != null &&
        widget.dataApprover.approvers!.isNotEmpty &&
        widget.dataApprover.approvers!
            .every((approver) => approver.status?.toLowerCase() == 'approved');
    final allRejected = widget.dataApprover.approvers != null &&
        widget.dataApprover.approvers!.isNotEmpty &&
        widget.dataApprover.approvers!
            .every((approver) => approver.status?.toLowerCase() == 'rejected');
    String formatDate(String updatedAt) {
      DateTime updatedAtDateTime = DateTime.parse(updatedAt);
      return DateFormat('dd-MM-yyyy').format(updatedAtDateTime);
    }

    String date = formatDate(widget.dataApprover.createdAt!);
    final aprovers = widget.dataApprover.approvers ?? [];
    final approversWithComments = aprovers
        .where((a) => (a.comments?.trim().isNotEmpty ?? false))
        .toList();
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Stack(children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              Column(
              children: [
                ///Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.4),
                                spreadRadius: 5,
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]),
                        child: const Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0, top: 0.0),
                      child: Text(
                        AppLocalizations.of(context)!.approvals,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: NasColors.darkBlue,
                        ),
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed:(){
                        printPdf();
                      },
                      icon: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.4),
                              spreadRadius: 5,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.print_outlined,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                ///created at
                Row(
                  children: [
                    Icon(
                      widget.dataApprover.requestData!.first.leaveType == 'sickLeave'
                          ? Icons.sick_outlined : widget.dataApprover.requestData!.first.leaveType == 'annualLeave'
                          ? Icons.calendar_today_outlined : widget.dataApprover.requestData!.first.leaveType == 'casualLeave'
                          ? Icons.beach_access_outlined : widget.dataApprover.requestType == 'loanRequest'
                          ? Icons.payments_outlined : Icons.description_outlined,
                      size: 30,
                      color: Colors.black,
                    ),
                    Spacer(),
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        '${AppLocalizations.of(context)!.createAt} $date',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight:
                          FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ///Profile section
                Row(
                  children: [
                    Container(
                      height: 90,
                      width: 85,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: const DecorationImage(
                          image: AssetImage(
                              'images/DP.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: 180,
                      child: Column(
                        children: [
                          Align(
                            alignment:
                            Alignment.topLeft,
                            child: Text(
                              "${widget.dataApprover.employeeName}",
                              style:
                              GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              _translateRequestSubtype2(widget.dataApprover.subType != null ? widget.dataApprover.subType!.replaceAllMapped(RegExp(r'([a-z])([A-Z])'),
                                    (Match match) => '${match.group(1)} ${match.group(2)}',
                              ).replaceFirst(widget.dataApprover.subType![0], widget.dataApprover.subType![0].toUpperCase()) : '', context),
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Spacer(),
                    Container(
                      height: 30,
                      width: 75,
                      decoration:
                      BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: _getColorForVerificationStatus(
                          "${widget.dataApprover.approvers!.firstWhere((approver) => approver.approverId == singletonClass.getJWTModel()?.employeeId,).status}"),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          _translateStatus(
                            widget.dataApprover.approvers!.firstWhere((approver) => approver.approverId == singletonClass.getJWTModel()?.employeeId,).status,
                            context,
                          ),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ///Request Data of every request
                if(widget.dataApprover.requestType == 'allowanceIncrement')...[
                  ///date
                  Row(
                    children: [
                      Align(
                          alignment:
                          Alignment.topLeft,
                          child: Text(
                            "${AppLocalizations.of(context)!.date}:",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          )
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                            ? singletonClass.formatDate2(widget.dataApprover.requestData!.first.date, context)
                            : AppLocalizations.of(context)!.noData,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  ///amount
                  Row(
                    children: [
                      Align(
                          alignment:
                          Alignment.topLeft,
                          child: Text(
                            "${AppLocalizations.of(context)!.amount}:",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          )
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                            ? "${widget.dataApprover.requestData!.first.amount ?? "---"}"
                            : AppLocalizations.of(context)!.noData,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  /// Note
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // align top
                    children: [
                      Text(
                        "${AppLocalizations.of(context)!.note}:",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 5),
                      // Make the content flexible
                      Expanded(
                        child: Text(
                          "${widget.dataApprover.reason}",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ///Request Type
                  Row(
                    children: [
                      Text(
                        "Request Type - ",
                        style: GoogleFonts.inter(
                          fontWeight:
                          FontWeight.bold,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      Align(
                        alignment:
                        Alignment.topLeft,
                        child: Text(
                          '${widget.dataApprover.requestType}',
                          style:
                          GoogleFonts.inter(
                            fontWeight:
                            FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if(widget.dataApprover.requestType == 'overTimeRequest')...[
                  ///date
                  Row(
                    children: [
                      Align(
                          alignment:
                          Alignment.topLeft,
                          child: Text(
                            "${AppLocalizations.of(context)!.date}:",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          )
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                            ? singletonClass.formatDate2(widget.dataApprover.requestData!.first.date, context)
                            : AppLocalizations.of(context)!.noData,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  ///OverTime Hours
                  Row(
                    children: [
                      Text(
                        "${AppLocalizations.of(context)!.overTime}:",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                            ? "${widget.dataApprover.requestData!.first.overTimeHours ?? "---"} ${AppLocalizations.of(context)!.h}"
                            : AppLocalizations.of(context)!.noData,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  ///Paid As
                  Row(
                    children: [
                      Text(
                        "${AppLocalizations.of(context)!.paidAs}:",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                                ? "${AppLocalizations.of(context)!.type}: ${widget.dataApprover.requestData!.first.paidAs!["type"] ?? "---"}"
                                : AppLocalizations.of(context)!.noData,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                                ? "${AppLocalizations.of(context)!.amount}: ${widget.dataApprover.requestData!.first.paidAs!["amount"] ?? "---"}"
                                : AppLocalizations.of(context)!.noData,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                                ? "${AppLocalizations.of(context)!.totalAmount}: ${widget.dataApprover.requestData!.first.paidAs!["totalAmount"] ?? "---"}"
                                : AppLocalizations.of(context)!.noData,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  /// Note
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // align top
                    children: [
                      Text(
                        "${AppLocalizations.of(context)!.note}:",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 5),
                      // Make the content flexible
                      Expanded(
                        child: Text(
                          "${widget.dataApprover.reason}",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ///Request Type
                  Row(
                    children: [
                      Text(
                        "Request Type - ",
                        style: GoogleFonts.inter(
                          fontWeight:
                          FontWeight.bold,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      Align(
                        alignment:
                        Alignment.topLeft,
                        child: Text(
                          '${widget.dataApprover.requestType}',
                          style:
                          GoogleFonts.inter(
                            fontWeight:
                            FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (widget.dataApprover.requestType == "loanRequest")...[
                  ///Duration
                  Row(
                    children: [
                      Align(
                          alignment:
                          Alignment.topLeft,
                          child: Text(
                            "${AppLocalizations.of(context)!.duration}:",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          )
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                            ? "${widget.dataApprover.requestData!.first.loanDuration ?? "---"} ${AppLocalizations.of(context)!.month}"
                            : AppLocalizations.of(context)!.noData,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ///Total loan amount
                  Row(
                    children: [
                      Align(
                        alignment:
                        Alignment.topLeft,
                        child: Text(
                          "${AppLocalizations.of(context)!.totalLoanAmount}: ",
                          style: GoogleFonts.inter(
                            fontWeight:
                            FontWeight.bold,
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            widget.dataApprover.requestData != null &&
                                widget.dataApprover.requestData!.isNotEmpty
                                ? "${widget.dataApprover.requestData!.first.loanAmount}"
                                : AppLocalizations.of(context)!.noData,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ///loan Installment
                  Row(
                    children: [
                      Align(
                        alignment:
                        Alignment.topLeft,
                        child: Text(
                          "${AppLocalizations.of(context)!.loanInstallment}: ",
                          style: GoogleFonts.inter(
                            fontWeight:
                            FontWeight.bold,
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            widget.dataApprover.requestData !=
                                null &&
                                widget.dataApprover
                                    .requestData!
                                    .isNotEmpty
                                ? "${widget.dataApprover.requestData!.first.loanInstallment ?? "---"}"
                                : AppLocalizations.of(
                                context)!
                                .noData,
                            style: GoogleFonts
                                .inter(
                              fontWeight:
                              FontWeight
                                  .bold,
                              color:
                              Colors.grey,
                              fontSize: 15,
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ///Loan Cycle
                  Row(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "${AppLocalizations.of(context)!.loanCycle}: ",
                          style: GoogleFonts.inter(
                            fontWeight:
                            FontWeight.bold,
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Align(
                          alignment:
                          Alignment.topLeft,
                          child: Text(
                            widget.dataApprover.requestData !=
                                null &&
                                widget.dataApprover
                                    .requestData!
                                    .isNotEmpty
                                ? "${widget.dataApprover.requestData!.first.loanCycle}"
                                : AppLocalizations.of(
                                context)!
                                .noData,
                            style: GoogleFonts
                                .inter(
                              fontWeight:
                              FontWeight
                                  .bold,
                              color:
                              Colors.grey,
                              fontSize: 15,
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(height: 15),
                  /// Note
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // align top
                    children: [
                      Text(
                        "${AppLocalizations.of(context)!.note}:",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 5),
                      // Make the content flexible
                      Expanded(
                        child: Text(
                          "${widget.dataApprover.reason}",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ///Request Type
                  Row(
                    children: [
                      Text(
                        "Request Type - ",
                        style: GoogleFonts.inter(
                          fontWeight:
                          FontWeight.bold,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      Align(
                        alignment:
                        Alignment.topLeft,
                        child: Text(
                          '${widget.dataApprover.requestType}',
                          style:
                          GoogleFonts.inter(
                            fontWeight:
                            FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if(widget.dataApprover.requestType == 'attendanceRequest')...[
                  ///date
                  Row(
                    children: [
                      Align(
                          alignment:
                          Alignment.topLeft,
                          child: Text(
                            "${AppLocalizations.of(context)!.date}:",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          )
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                            ? singletonClass.formatDate2(widget.dataApprover.requestData!.first.attendanceDate, context)
                            : AppLocalizations.of(context)!.noData,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  ///attendance Time
                  Row(
                    children: [
                      Align(
                          alignment:
                          Alignment.topLeft,
                          child: Text(
                            "${AppLocalizations.of(context)!.time}:",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          )
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                            ? "${widget.dataApprover.requestData!.first.attendanceTime ?? "---"}"
                            : AppLocalizations.of(context)!.noData,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  ///Attendance Type
                  Row(
                    children: [
                      Align(
                          alignment:
                          Alignment.topLeft,
                          child: Text(
                            "${AppLocalizations.of(context)!.type}:",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          )
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                            ? "${widget.dataApprover.requestData!.first.punchingType ?? "---"}"
                            : AppLocalizations.of(context)!.noData,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  /// Note
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${AppLocalizations.of(context)!.note}:",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 5),
                      // Make the content flexible
                      Expanded(
                        child: Text(
                          "${widget.dataApprover.reason}",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ///Request Type
                  Row(
                    children: [
                      Text(
                        "Request Type - ",
                        style: GoogleFonts.inter(
                          fontWeight:
                          FontWeight.bold,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      Align(
                        alignment:
                        Alignment.topLeft,
                        child: Text(
                          '${widget.dataApprover.requestType}',
                          style:
                          GoogleFonts.inter(
                            fontWeight:
                            FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (widget.dataApprover.requestType == "expenseRequest")...[
                  ///expense Data
                  Row(
                    children: [
                      Align(
                          alignment:
                          Alignment.topLeft,
                          child: Text(
                            "${AppLocalizations.of(context)!.expense} ${AppLocalizations.of(context)!.date}:",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          )
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                            ? singletonClass.formatDate2(widget.dataApprover.requestData!.first.expenseDate, context)
                            : AppLocalizations.of(context)!.noData,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  ///amount
                  Row(
                    children: [
                      Align(
                          alignment:
                          Alignment.topLeft,
                          child: Text(
                            "${AppLocalizations.of(context)!.amount}:",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          )
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                            ? "${widget.dataApprover.requestData!.first.amount ?? "---"}"
                            : AppLocalizations.of(context)!.noData,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  ///purpose
                  Row(
                    children: [
                      Align(
                          alignment:
                          Alignment.topLeft,
                          child: Text(
                            "${AppLocalizations.of(context)!.purpose}:",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          )
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                            ? "${widget.dataApprover.requestData!.first.purpose ?? "---"}"
                            : AppLocalizations.of(context)!.noData,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  ///category
                  Row(
                    children: [
                      Align(
                          alignment:
                          Alignment.topLeft,
                          child: Text(
                            "${AppLocalizations.of(context)!.category}:",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          )
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                            ? "${widget.dataApprover.requestData!.first.category ?? "---"}"
                            : AppLocalizations.of(context)!.noData,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  ///payment method
                  Row(
                    children: [
                      Align(
                          alignment:
                          Alignment.topLeft,
                          child: Text(
                            "${AppLocalizations.of(context)!.paymentMethods}:",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          )
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                            ? "${widget.dataApprover.requestData!.first.paymentMethod ?? "---"}"
                            : AppLocalizations.of(context)!.noData,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  ///transaction type
                  Row(
                    children: [
                      Align(
                          alignment:
                          Alignment.topLeft,
                          child: Text(
                            "${AppLocalizations.of(context)!.transactionType}:",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          )
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                            ? "${widget.dataApprover.requestData!.first.transactionType ?? "---"}"
                            : AppLocalizations.of(context)!.noData,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  /// Note
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // align top
                    children: [
                      Text(
                        "${AppLocalizations.of(context)!.note}:",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 5),
                      // Make the content flexible
                      Expanded(
                        child: Text(
                          "${widget.dataApprover.reason}",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ///Request Type
                  Row(
                    children: [
                      Text(
                        "Request Type - ",
                        style: GoogleFonts.inter(
                          fontWeight:
                          FontWeight.bold,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      Align(
                        alignment:
                        Alignment.topLeft,
                        child: Text(
                          '${widget.dataApprover.requestType}',
                          style:
                          GoogleFonts.inter(
                            fontWeight:
                            FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if(widget.dataApprover.requestType == 'documentRequest')...[
                  ///date
                  Row(
                    children: [
                      Align(
                          alignment:
                          Alignment.topLeft,
                          child: Text(
                            "${AppLocalizations.of(context)!.date}:",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          )
                      ),
                      const SizedBox(width: 5),
                      Text(
                        (widget.dataApprover.requestData != null &&
                            widget.dataApprover.requestData!.isNotEmpty &&
                            widget.dataApprover.requestData!.first.date != null)
                            ? singletonClass.formatDate2(
                          widget.dataApprover.requestData!.first.date!,
                          context,
                        )
                            : AppLocalizations.of(context)!.noData,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  ///doc type
                  Row(
                    children: [
                      Align(
                          alignment:
                          Alignment.topLeft,
                          child: Text(
                            "${AppLocalizations.of(context)!.document} ${AppLocalizations.of(context)!.type}:",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          )
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                            ? "${widget.dataApprover.requestData!.first.documentType ?? "---"}"
                            : AppLocalizations.of(context)!.noData,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  ///name
                  Row(
                    children: [
                      Align(
                          alignment:
                          Alignment.topLeft,
                          child: Text(
                            "${AppLocalizations.of(context)!.document} ${AppLocalizations.of(context)!.name}:",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          )
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                            ? "${widget.dataApprover.requestData!.first.documentName ?? "---"}"
                            : AppLocalizations.of(context)!.noData,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  /// Note
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // align top
                    children: [
                      Text(
                        "${AppLocalizations.of(context)!.note}:",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 5),
                      // Make the content flexible
                      Expanded(
                        child: Text(
                          "${widget.dataApprover.reason}",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ///Request Type
                  Row(
                    children: [
                      Text(
                        "Request Type - ",
                        style: GoogleFonts.inter(
                          fontWeight:
                          FontWeight.bold,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      Align(
                        alignment:
                        Alignment.topLeft,
                        child: Text(
                          '${widget.dataApprover.requestType}',
                          style:
                          GoogleFonts.inter(
                            fontWeight:
                            FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if(widget.dataApprover.requestType == 'leaveRequest')...[
                  if(widget.dataApprover.subType == "shortLeave")...[
                    ///date
                    Row(
                      children: [
                        Align(
                            alignment:
                            Alignment.topLeft,
                            child: Text(
                              "${AppLocalizations.of(context)!.date}:",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            )
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                              ? singletonClass.formatDate2(widget.dataApprover.requestData!.first.startDate , context)
                              : AppLocalizations.of(context)!.noData,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ///Time
                    Row(
                      children: [
                        Align(
                            alignment:
                            Alignment.topLeft,
                            child: Text(
                              "${AppLocalizations.of(context)!.time}:",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            )
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                              ? singletonClass.formatDateTime(widget.dataApprover.requestData!.first.startDate)
                              : AppLocalizations.of(context)!.noData,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          " - ",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                              ? singletonClass.formatDateTime(widget.dataApprover.requestData!.first.endDate)
                              : AppLocalizations.of(context)!.noData,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    ///duration
                    Row(
                      children: [
                        Align(
                            alignment:
                            Alignment.topLeft,
                            child: Text(
                              "${AppLocalizations.of(context)!.duration}:",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            )
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                              ? "${widget.dataApprover.requestData!.first.duration ?? "---"} ${AppLocalizations.of(context)!.h}"
                              : AppLocalizations.of(context)!.noData,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    ///date
                    Row(
                      children: [
                        Align(
                            alignment:
                            Alignment.topLeft,
                            child: Text(
                              "${AppLocalizations.of(context)!.date}:",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            )
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                              ? singletonClass.formatDate2(widget.dataApprover.requestData!.first.startDate , context)
                              : AppLocalizations.of(context)!.noData,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          " - ",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                              ? singletonClass.formatDate2(widget.dataApprover.requestData!.first.endDate, context)
                              : AppLocalizations.of(context)!.noData,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    ///duration
                    Row(
                      children: [
                        Align(
                            alignment:
                            Alignment.topLeft,
                            child: Text(
                              "${AppLocalizations.of(context)!.duration}:",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            )
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                              ? "${widget.dataApprover.requestData!.first.duration ?? "---"} ${AppLocalizations.of(context)!.days}"
                              : AppLocalizations.of(context)!.noData,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 15),
                  /// Note
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // align top
                    children: [
                      Text(
                        "${AppLocalizations.of(context)!.note}:",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 5),
                      // Make the content flexible
                      Expanded(
                        child: Text(
                          "${widget.dataApprover.reason}",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ///Request Type
                  Row(
                    children: [
                      Text(
                        "Request Type - ",
                        style: GoogleFonts.inter(
                          fontWeight:
                          FontWeight.bold,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      Align(
                        alignment:
                        Alignment.topLeft,
                        child: Text(
                          '${widget.dataApprover.requestType}',
                          style:
                          GoogleFonts.inter(
                            fontWeight:
                            FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if(widget.dataApprover.requestType == 'specialLeaveRequest')...[
                  ///date
                  Row(
                    children: [
                      Align(
                          alignment:
                          Alignment.topLeft,
                          child: Text(
                            "${AppLocalizations.of(context)!.date}:",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          )
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                            ? "${singletonClass.formatDate2(widget.dataApprover.requestData!.first.startDate, context)} - ${singletonClass.formatDate2(widget.dataApprover.requestData!.first.endDate, context)}"
                            : AppLocalizations.of(context)!.noData,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  ///duration
                  Row(
                    children: [
                      Align(
                          alignment:
                          Alignment.topLeft,
                          child: Text(
                            "${AppLocalizations.of(context)!.duration}:",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          )
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
                            ? "${widget.dataApprover.requestData!.first.duration ?? "---"} ${AppLocalizations.of(context)!.days}"
                            : AppLocalizations.of(context)!.noData,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  /// Note
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // align top
                    children: [
                      Text(
                        "${AppLocalizations.of(context)!.note}:",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 5),
                      // Make the content flexible
                      Expanded(
                        child: Text(
                          "${widget.dataApprover.reason}",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ///Request Type
                  Row(
                    children: [
                      Text(
                        "Request Type - ",
                        style: GoogleFonts.inter(
                          fontWeight:
                          FontWeight.bold,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      Align(
                        alignment:
                        Alignment.topLeft,
                        child: Text(
                          '${widget.dataApprover.requestType}',
                          style:
                          GoogleFonts.inter(
                            fontWeight:
                            FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                ///Approver List
                const SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: NasColors.completed,
                                ),
                              ),
                              Container(
                                height: 10,
                                width: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "➡️",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Container(
                          width: 40,
                          height: 2,
                          color: Colors.grey,
                        ),
                      ),
                      ...[
                        if (widget.dataApprover.approvers != null && widget.dataApprover.approvers!.isNotEmpty)
                          for (int i = 0; i < widget.dataApprover.approvers!.length; i++) ...[
                            Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      height: 25,
                                      width: 25,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _getColorForApproverStatus(
                                            widget.dataApprover.approvers![i].status),
                                      ),
                                    ),
                                    Container(
                                      height: 10,
                                      width: 10,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  widget.dataApprover.approvers![i].approverName ?? '---',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            if (i != widget.dataApprover.approvers!.length - 1)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Container(
                                  width: 40,
                                  height: 2,
                                  color: Colors.grey,
                                ),
                              ),
                          ]
                        else
                          Text(
                            '---',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Container(
                          width: 40,
                          height: 2,
                          color: Colors.grey,
                        ),
                      ),
                      Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: allApproved ? NasColors.completed : allRejected ? Colors.red : NasColors.pending,
                                ),
                              ),
                              Container(
                                height: 10,
                                width: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            allApproved ? "✅" : allRejected ? "❌" : "⏳",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                ///Attachments
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.attachment,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                (widget.dataApprover.attachments != null &&
                    widget.dataApprover.attachments!.isNotEmpty &&
                    widget.dataApprover.attachments!.first.url != null &&
                    widget.dataApprover.attachments!.first.url!.isNotEmpty)
                    ? Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final url = widget.dataApprover.attachments!
                                .first.url;

                            if (url == null || url.isEmpty) {
                              debugPrint("Invalid attachment URL");
                              return;
                            }

                            final inlineExtensions = [
                              '.pdf',
                              '.doc',
                              '.docx',
                              '.xls',
                              '.xlsx',
                              '.ppt',
                              '.pptx',
                              '.jpg',
                              '.jpeg',
                              '.png',
                              '.gif',
                              '.bmp',
                              '.webp',
                              '.heic',
                              '.heif',
                              '.tiff'
                            ];

                            final lower = url.toLowerCase();
                            final isDocs = inlineExtensions
                                .any((ext) => lower.endsWith(ext));

                            if (isDocs) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FileViewerScreen(
                                    url: url,
                                    fileName:
                                    "${widget.dataApprover.attachments!.first.type}",
                                  ),
                                ),
                              );
                            } else {
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url),
                                    mode: LaunchMode.externalApplication);
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                      content:
                                      Text("Unable to open file")),
                                );
                              }
                            }
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.insert_drive_file,
                                  color: Colors.blueAccent, size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "${widget.dataApprover.attachments!.first.type}",
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          final url = widget.dataApprover.attachments!
                              .first.url;
                          if (url != null && url.isNotEmpty) {
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url),
                                  mode: LaunchMode.externalApplication);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Unable to open file")),
                              );
                            }
                          } else {
                            debugPrint('Invalid download URL');
                          }
                        },
                        child: const Icon(Icons.download,
                            color: Colors.blueAccent, size: 22),
                      ),
                    ],
                  ),
                )
                    : Row(
                  children: [
                    const Text(
                      "---",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                ///Comments
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.comments,
                      style: GoogleFonts.inter(
                        fontWeight:
                        FontWeight.bold,
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (approversWithComments.isNotEmpty)
                  ...approversWithComments.map((c) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${c.approverName ?? '---'} • ${singletonClass.formatDate2(c.timeStamps.toString(), context)}",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            c.comments ?? "---",
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  })
                else
                  Row(
                    children: [
                      Text(
                        "---",
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 25),
              ],
            ),]
          ),
          if (isLoading) Loader()
        ]),
      ),
    );
  }

  String _translateRequestSubtype2(String? status, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    switch (status) {
      case 'Sick Leave':
        return localizations.sickLeave;
      case 'Annual Leave':
        return localizations.annualLeave;
      case 'Casual Leave':
        return localizations.casualLeave;
      case 'Advancesalaryrequest':
        return localizations.advanceSalaryRequest;
      case 'LongTermloanrequest':
        return localizations.longTermLoanRequest;
      case "Housingallowance":
        return localizations.housingAllowance;
      case "Travelingallowance":
        return localizations.travellingAllowance;
      case 'Salaryincrementalallowance':
        return localizations.salaryIncrementalAllowance;
      case "Salaryslip":
        return localizations.salarySlip;
      case "Promotionalletter":
        return localizations.promotionalLetter;
      case "Contract":
        return localizations.contract;
      case "ID Card":
        return localizations.idCard;
      case "Advanceexpense":
        return localizations.advanceExpense;
      case "Businessexpense":
        return localizations.businessExpense;
      case "Reimbursement":
        return localizations.reimbursement;
      case "Disbursement":
        return localizations.disbursement;
      case "Star":
        return localizations.star;
      case "Moon":
        return localizations.moon;
      case "Badbehaviour":
        return localizations.badBehaviour;
      case "Marraigeleave":
        return localizations.marriageLeave;
      case "Exams Leave":
        return localizations.examLeave;
      case "Exam Leave":
        return localizations.examLeave;
      case "Death Leave":
        return localizations.deathLeave;
      case "Specialdocument":
        return localizations.specialDocument;
      default:
        return status!;
    }
  }

  Color _getColorForVerificationStatus(String verificationStatus) {
    switch (verificationStatus) {
      case 'approved':
        return NasColors.completed;
      case 'pending':
        return NasColors.pending;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _translateStatus(String? status, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (status == null) {
      return localizations.noData;
    }

    switch (status) {
      case 'pending':
        return localizations.pending;
      case 'approved':
        return localizations.approved;
      case 'rejected':
        return localizations.rejected;
      case 'cancelled':
        return localizations.cancelled;
      default:
        return status;
    }
  }

  Color _getColorForApproverStatus(String? approverStatus) {
    if (approverStatus == null ||
        approverStatus.isEmpty ||
        approverStatus == 'pending') {
      return NasColors.pending;
    } else if (approverStatus == "rejected"){
      return Colors.red;
    } else {
      return NasColors.completed;
    }
  }

  ///PATCH API CALL
  void patchRequestData(String? requestID, String status,
      Map<String, dynamic> requestData) async {
    String? employeeId = requestData['employeeId'];
    String url =
        '${singletonClass.baseURL}/request/acceptLeave/$employeeId/$requestID';

    String? currentApproverId = singletonClass.getJWTModel()?.employeeId;
    String? currentApproverName = singletonClass.getJWTModel()?.userName;

    Map<String, dynamic> data = {
      "approverId": currentApproverId,
      "approverName": currentApproverName,
      "status": status,
      "timeStamps": DateTime.now().toIso8601String(),
      "comments": _comment.text,
    };

    String jsonData = jsonEncode(data);
    log("PATCH DATA JSON $jsonData");

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: singletonClass.getHeaders(),
        body: jsonData,
      );

      setState(() {
        isLoading = false;
      });

      final decodedResponse = json.decode(response.body);

      if (response.statusCode == 200 && decodedResponse['statusCode'] == 200) {
        await QuickAlert.show(
          autoCloseDuration: const Duration(seconds: 2),
          showCancelBtn: false,
          showConfirmBtn: false,
          context: context,
          title: AppLocalizations.of(context)!.success,
          type: QuickAlertType.success,
        );
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MainScreen(
                      index: 2,
                      selectedIndex: 1,
                    showBanner: false
                    )));
      } else {
        await QuickAlert.show(
          autoCloseDuration: const Duration(seconds: 2),
          showCancelBtn: false,
          showConfirmBtn: false,
          context: context,
          title: AppLocalizations.of(context)!.internalServerError,
          type: QuickAlertType.error,
        );
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Failed to send data. Error: $error');
      await QuickAlert.show(
        autoCloseDuration: const Duration(seconds: 2),
        showCancelBtn: false,
        showConfirmBtn: false,
        context: context,
        title: 'Failed to send data. Error: $error',
        type: QuickAlertType.error,
      );
    }
  }

  String htmlRow(String label, String value) {
    final escapedValue = value.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;').replaceAll("'", '&#39;');
    return '<div style="margin-bottom: 10px;"><strong>$label:</strong> <span>$escapedValue</span></div>';
  }

  String buildApproversWorkflow() {
    final data = widget.dataApprover;
    if (data.approvers == null || data.approvers!.isEmpty) {
      return '<div style="margin: 20px 0;"><h3 style="margin-bottom: 15px;">Approval Workflow</h3><div style="display: flex; align-items: center; justify-content: center;"><div style="text-align: center; margin: 0 10px;"><div style="width: 25px; height: 25px; border-radius: 50%; background-color: #4CAF50; margin: 0 auto 5px;"></div><span>➡️</span></div><div style="width: 40px; height: 2px; background-color: #ccc;"></div><div style="text-align: center; margin: 0 10px;"><span>---</span></div><div style="width: 40px; height: 2px; background-color: #ccc;"></div><div style="text-align: center; margin: 0 10px;"><div style="width: 25px; height: 25px; border-radius: 50%; background-color: #FFA726; margin: 0 auto 5px;"></div><span>⏳</span></div></div></div>';
    }

    bool allApproved = data.approvers!.every((a) => a.status == 'approved');
    bool allRejected = data.approvers!.any((a) => a.status == 'rejected');
    String finalColor = allApproved ? '#4CAF50' : allRejected ? '#F44336' : '#FFA726';
    String finalEmoji = allApproved ? '✅' : allRejected ? '❌' : '⏳';
    String approversHtml = '';

    for (int i = 0; i < data.approvers!.length; i++) {
      final approver = data.approvers![i];
      String statusColor = _getColorForApproverStatus(approver.status).value.toRadixString(16).substring(2);
      String statusText = approver.status ?? 'pending';
      String statusEmoji = approver.status == 'approved' ? '✅' : approver.status == 'rejected' ? '❌' : '⏳';
      approversHtml += '<div style="text-align: center; margin: 0 10px;"><div style="width: 25px; height: 25px; border-radius: 50%; background-color: #$statusColor; margin: 0 auto 5px; position: relative;"><div style="width: 10px; height: 10px; border-radius: 50%; background-color: white; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);"></div></div><p style="font-size: 12px; margin: 5px 0 0 0;">${approver.approverName ?? '---'}</p><p style="font-size: 10px; margin: 2px 0 0 0; color: #666;">$statusEmoji $statusText</p></div>';
      if (i < data.approvers!.length - 1) approversHtml += '<div style="width: 40px; height: 2px; background-color: #ccc;"></div>';
    }

    return '<div style="margin: 20px 0;"><h3 style="margin-bottom: 15px;">Approval Workflow</h3><div style="display: flex; align-items: center; justify-content: center; flex-wrap: wrap;"><div style="text-align: center; margin: 0 10px;"><div style="width: 25px; height: 25px; border-radius: 50%; background-color: #4CAF50; margin: 0 auto 5px; position: relative;"><div style="width: 10px; height: 10px; border-radius: 50%; background-color: white; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);"></div></div><span>➡️</span></div><div style="width: 40px; height: 2px; background-color: #ccc;"></div>$approversHtml<div style="width: 40px; height: 2px; background-color: #ccc;"></div><div style="text-align: center; margin: 0 10px;"><div style="width: 25px; height: 25px; border-radius: 50%; background-color: $finalColor; margin: 0 auto 5px; position: relative;"><div style="width: 10px; height: 10px; border-radius: 50%; background-color: white; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);"></div></div><span>$finalEmoji</span></div></div></div>';
  }

  String buildCommentsSection() {
    final data = widget.dataApprover;
    final t = AppLocalizations.of(context)!;
    List approversWithComments = [];
    if (data.approvers != null) approversWithComments = data.approvers!.where((a) => a.comments != null && a.comments!.isNotEmpty).toList();
    if (approversWithComments.isEmpty) return '<div style="margin: 20px 0;"><h3 style="margin-bottom: 15px;">${t.comments}</h3><p>Not Available</p></div>';
    String commentsHtml = '';
    for (var comment in approversWithComments) {
      final name = comment.approverName ?? '---';
      final timestamp = comment.timeStamps != null ? singletonClass.formatDate2(comment.timeStamps.toString(), context) : '---';
      final commentText = comment.comments ?? '---';
      commentsHtml += '<div style="background-color: #f5f5f5; border-radius: 8px; padding: 10px; margin-bottom: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);"><p style="font-size: 13px; font-weight: bold; margin: 0 0 10px 0; color: black;">$name • $timestamp</p><p style="font-size: 15px; color: black; margin: 0;">$commentText</p></div>';
    }
    return '<div style="margin: 20px 0;"><h3 style="margin-bottom: 15px;">${t.comments}</h3>$commentsHtml</div>';
  }

  String buildHtmlContent() {
    try {
      final t = AppLocalizations.of(context)!;
      final data = widget.dataApprover;
      String content = '';
      if (data.requestType == 'allowanceIncrement') {
        content += htmlRow(t.date, data.requestData != null && data.requestData!.isNotEmpty ? singletonClass.formatDate2(data.requestData!.first.date, context) : t.noData);
        content += htmlRow(t.amount, data.requestData != null && data.requestData!.isNotEmpty ? "${data.requestData!.first.amount ?? '---'}" : t.noData);
        content += htmlRow(t.note, data.reason ?? '---');
        content += htmlRow('Request Type', data.requestType ?? '---');
      } else if (data.requestType == 'overTimeRequest') {
        content += htmlRow(t.date, data.requestData != null && data.requestData!.isNotEmpty ? singletonClass.formatDate2(data.requestData!.first.date, context) : t.noData);
        content += htmlRow(t.overTime, data.requestData != null && data.requestData!.isNotEmpty ? "${data.requestData!.first.overTimeHours ?? '---'} ${t.h}" : t.noData);
        if (data.requestData != null && data.requestData!.isNotEmpty && data.requestData!.first.paidAs != null) {
          final paidAs = data.requestData!.first.paidAs!;
          content += '<div style="margin: 15px 0;"><strong>${t.paidAs}:</strong></div>';
          content += htmlRow(t.type, paidAs['type']?.toString() ?? '---');
          content += htmlRow(t.amount, paidAs['amount']?.toString() ?? '---');
          content += htmlRow(t.totalAmount, paidAs['totalAmount']?.toString() ?? '---');
        }
        content += htmlRow(t.note, data.reason ?? '---');
        content += htmlRow('Request Type', data.requestType ?? '---');
      } else if (data.requestType == 'loanRequest') {
        final r = data.requestData?.first;
        content += htmlRow(t.duration, r != null ? "${r.loanDuration ?? '---'} ${t.month}" : '---');
        content += htmlRow(t.totalLoanAmount, r?.loanAmount?.toString() ?? '---');
        content += htmlRow(t.loanInstallment, r?.loanInstallment?.toString() ?? '---');
        content += htmlRow(t.loanCycle, r?.loanCycle ?? '---');
        content += htmlRow(t.note, data.reason ?? '---');
        content += htmlRow('Request Type', data.requestType ?? '---');
      } else if (data.requestType == 'attendanceRequest') {
        final r = data.requestData?.first;
        content += htmlRow(t.date, r != null ? singletonClass.formatDate2(r.attendanceDate, context) : '---');
        content += htmlRow(t.time, r?.attendanceTime ?? '---');
        content += htmlRow(t.type, r?.punchingType ?? '---');
        content += htmlRow(t.note, data.reason ?? '---');
        content += htmlRow('Request Type', data.requestType ?? '---');
      } else if (data.requestType == 'expenseRequest') {
        final r = data.requestData?.first;
        content += htmlRow('${t.expense} ${t.date}', r != null ? singletonClass.formatDate2(r.expenseDate, context) : '---');
        content += htmlRow(t.amount, r?.amount?.toString() ?? '---');
        content += htmlRow(t.purpose, r?.purpose ?? '---');
        content += htmlRow(t.category, r?.category ?? '---');
        content += htmlRow(t.paymentMethods, r?.paymentMethod ?? '---');
        content += htmlRow(t.transactionType, r?.transactionType ?? '---');
        content += htmlRow(t.note, data.reason ?? '---');
        content += htmlRow('Request Type', data.requestType ?? '---');
      } else if (data.requestType == 'documentRequest') {
        final r = data.requestData?.first;
        content += htmlRow(t.date, r != null && r.date != null ? singletonClass.formatDate2(r.date!, context) : t.noData);
        content += htmlRow('${t.document} ${t.type}', r?.documentType ?? '---');
        content += htmlRow('${t.document} ${t.name}', r?.documentName ?? '---');
        content += htmlRow(t.note, data.reason ?? '---');
        content += htmlRow('Request Type', data.requestType ?? '---');
      } else if (data.requestType == 'leaveRequest') {
        final r = data.requestData?.first;
        if (data.subType == 'shortLeave') {
          content += htmlRow(t.date, r != null ? singletonClass.formatDate2(r.startDate, context) : t.noData);
          content += htmlRow(t.time, r != null ? "${singletonClass.formatDateTime(r.startDate)} - ${singletonClass.formatDateTime(r.endDate)}" : t.noData);
          content += htmlRow(t.duration, r != null ? "${r.duration ?? '---'} ${t.h}" : '---');
        } else {
          content += htmlRow(t.date, r != null ? "${singletonClass.formatDate2(r.startDate, context)} - ${singletonClass.formatDate2(r.endDate, context)}" : t.noData);
          content += htmlRow(t.duration, r != null ? "${r.duration ?? '---'} ${t.days}" : '---');
        }
        content += htmlRow(t.note, data.reason ?? '---');
        content += htmlRow('Request Type', data.requestType ?? '---');
      } else if (data.requestType == 'specialLeaveRequest') {
        final r = data.requestData?.first;
        content += htmlRow(t.date, r != null ? "${singletonClass.formatDate2(r.startDate, context)} - ${singletonClass.formatDate2(r.endDate, context)}" : t.noData);
        content += htmlRow(t.duration, r != null ? "${r.duration ?? '---'} ${t.days}" : '---');
        content += htmlRow(t.note, data.reason ?? '---');
        content += htmlRow('Request Type', data.requestType ?? '---');
      } else {
        content += htmlRow('Request Type', data.requestType ?? 'Unknown');
        content += htmlRow(t.note, data.reason ?? '---');
      }
      return content;
    } catch (e) {
      if (kDebugMode) print('Error building HTML content: $e');
      return '<div><strong>Error:</strong> Unable to generate content</div>';
    }
  }

  Future<String> generateFullHtml({required String headerUrl, required String footerUrl}) async {
    try {
      final body = buildHtmlContent();
      final approversWorkflow = buildApproversWorkflow();
      final commentsSection = buildCommentsSection();
      return '''
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { font-family: Arial, sans-serif; margin: 0; padding: 0; }
          img { display: block; width: 100%; }
          .header-img, .footer-img { margin: 0; padding: 0; }
          .content { margin: 20px; padding: 20px; }
          strong { color: black; font-weight: bold; }
          span { color: black; }
          div { line-height: 1.6; }
          h3 { color: black; font-weight: bold; margin: 20px 0 15px 0; }
        </style>
      </head>
      <body>
        <img class="header-img" src="$headerUrl" alt="Header"/>
        <div class="content">$body</div>
        $approversWorkflow
        $commentsSection
        <img class="footer-img" src="$footerUrl" alt="Footer"/>
      </body>
    </html>
    ''';
    } catch (e) {
      if (kDebugMode) print('Error generating HTML: $e');
      rethrow;
    }
  }


  Future<void> printPdf() async {
    try {
      final html = await generateFullHtml(headerUrl: singletonClass.headerUrl, footerUrl: singletonClass.footerUrl);
      await Printing.layoutPdf(onLayout: (format) async {
        try {
          return await Printing.convertHtml(format: format, html: html);
        } catch (e) {
          if (kDebugMode) print('Error converting HTML to PDF: $e');
          rethrow;
        }
      });
    } catch (e) {
      if (kDebugMode) print('Error printing PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating PDF: ${e.toString()}'), backgroundColor: Colors.red));
      }
    }
  }
}
