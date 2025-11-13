import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nashr/screens/pdf_viewer_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../request_controller/request_data_model.dart';

class SelfRequestDetailScreen extends StatefulWidget {
  final Data1 data1;
  const SelfRequestDetailScreen({super.key,required this.data1});

  @override
  State<SelfRequestDetailScreen> createState() => _SelfRequestDetailScreenState();
}

class _SelfRequestDetailScreenState extends State<SelfRequestDetailScreen> {
  SingletonClass singletonClass = SingletonClass();
  @override
  Widget build(BuildContext context) {
    final allApproved = widget.data1.approvers != null &&
        widget.data1.approvers!.isNotEmpty &&
        widget.data1.approvers!.every((approver) =>
        approver.status?.toLowerCase() == 'approved');
    String formatDate(String updatedAt) {
      DateTime updatedAtDateTime = DateTime.parse(updatedAt);
      return DateFormat('dd-MM-yyyy').format(updatedAtDateTime);
    }
    String date = formatDate(widget.data1.createdAt!);
    final startDate = widget.data1.requestData!.first.startDate;
    final endDate = widget.data1.requestData!.first.endDate;
    final int daysDiff = (startDate != null && endDate != null)
        ? DateTime.parse(endDate).difference(DateTime.parse(startDate)).inDays + 1
        : 0;
    final aprovers = widget.data1.approvers ?? [];
    final approversWithComments = aprovers.where((a) => (a.comments?.trim().isNotEmpty ?? false)).toList();
    return  Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Column(
          children: [
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
                    AppLocalizations.of(context)!.requests,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: NasColors.darkBlue,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            Row(
              children: [
                Icon(
                  widget.data1.requestData!.first.leaveType == 'sickLeave'
                      ? Icons.sick_outlined : widget.data1.requestData!.first.leaveType == 'annualLeave'
                      ? Icons.calendar_today_outlined : widget.data1.requestData!.first.leaveType == 'casualLeave'
                      ? Icons.beach_access_outlined : widget.data1.requestType == 'loanRequest'
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
                          "${widget.data1.employeeName}",
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
                          _translateRequestSubtype2(widget.data1.subType != null ? widget.data1.subType!.replaceAllMapped(RegExp(r'([a-z])([A-Z])'),
                                (Match match) => '${match.group(1)} ${match.group(2)}',
                          ).replaceFirst(widget.data1.subType![0], widget.data1.subType![0].toUpperCase()) : '', context),
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
                        widget.data1.status ?? 'default'),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _translateStatus(widget.data1.status, context),
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
                Align(
                  alignment:
                  Alignment.topLeft,
                  child: widget.data1.requestType == "loanRequest" ? Text(
                    widget.data1.requestData != null && widget.data1.requestData!.isNotEmpty
                        ? "${widget.data1.requestData!.first.loanDuration ?? "---"} ${AppLocalizations.of(context)!.month}"
                        : AppLocalizations.of(context)!.noData,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  )
                      : Text(
                    widget.data1.requestData != null &&
                        widget.data1.requestData!.isNotEmpty
                        ? "${widget.data1.requestData!.first.startDate?? "---"} - $daysDiff ${AppLocalizations.of(context)!.days} "
                        : AppLocalizations.of(context)!.noData,
                    style: GoogleFonts.inter(
                      fontWeight:
                      FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Text( "${AppLocalizations.of(context)!.note}:",
                  style: GoogleFonts.inter(
                    fontWeight:
                    FontWeight.bold,
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
                SizedBox(width: 5),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text("${widget.data1.reason}",
                    style:
                    GoogleFonts.inter(
                      fontWeight:
                      FontWeight.w500,
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
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
                    '${widget.data1.requestType}',
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
            const SizedBox(height: 15),
            if (widget.data1.requestType == 'loanRequest') ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Align(
                    alignment:
                    Alignment.topLeft,
                    child: Text(
                      "${AppLocalizations.of(context)!.totalLoanAmount} - ",
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
                        widget.data1.requestData != null &&
                            widget.data1.requestData!.isNotEmpty
                            ? "${widget.data1.requestData!.first.loanAmount}"
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
              Row(
                children: [
                  Align(
                    alignment:
                    Alignment.topLeft,
                    child: Text(
                      "${AppLocalizations.of(context)!.loanInstallment} - ",
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
                        widget.data1.requestData !=
                            null &&
                            widget.data1
                                .requestData!
                                .isNotEmpty
                            ? "${widget.data1.requestData!.first.loanInstallment}"
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
              Row(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "${AppLocalizations.of(context)!.loanCycle} - ",
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
                        widget.data1.requestData !=
                            null &&
                            widget.data1
                                .requestData!
                                .isNotEmpty
                            ? "${widget.data1.requestData!.first.loanCycle}"
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
              const SizedBox(height: 20),
            ],
            const SizedBox(height: 10),
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
                    if (widget.data1.approvers != null && widget.data1.approvers!.isNotEmpty)
                      for (int i = 0; i < widget.data1.approvers!.length; i++) ...[
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
                                        widget.data1.approvers![i].status),
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
                              widget.data1.approvers![i].approverName ?? '---',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (i != widget.data1.approvers!.length - 1)
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
                              color: allApproved ? NasColors.completed : NasColors.pending,
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
                        allApproved ? "✅" : "⏳",
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
            (widget.data1.attachments != null &&
                widget.data1.attachments!.isNotEmpty)
                ? Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Row(
                // ✅ changed from min → max
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final url = widget.data1.attachments!
                            .first.fileContent;

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
                                "${widget.data1.attachments!.first.fileName}",
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
                              "${widget.data1.attachments!.first.fileName}",
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
                      final url = widget.data1.attachments!
                          .first.fileContent;
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
        ),
      ),
    );
  }

  ///Helper method
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
    } else {
      return NasColors
          .completed;
    }
  }

}
