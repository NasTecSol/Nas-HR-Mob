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
import '../request_controller/approver_request_data_model.dart';

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
    String formatDate(String updatedAt) {
      DateTime updatedAtDateTime = DateTime.parse(updatedAt);
      return DateFormat('dd-MM-yyyy').format(updatedAtDateTime);
    }

    String date = formatDate(widget.dataApprover.createdAt!);
    final startDate = widget.dataApprover.requestData!.first.startDate;
    final endDate = widget.dataApprover.requestData!.first.endDate;

    // ✅ Avoid crash: check both dates
    final int daysDiff = (startDate != null && endDate != null)
        ? DateTime.parse(endDate).difference(DateTime.parse(startDate)).inDays +
            1
        : 0;
    final aprovers = widget.dataApprover.approvers ?? [];
    final approversWithComments = aprovers
        .where((a) => (a.comments?.trim().isNotEmpty ?? false))
        .toList();

    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Stack(
          children: [ Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
                      AppLocalizations.of(context)!.approvals,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: NasColors.darkBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Icon(
                    widget.dataApprover.requestData!.first.leaveType ==
                            'sickLeave'
                        ? Icons.sick_outlined
                        : widget.dataApprover.requestData!.first.leaveType ==
                                'annualLeave'
                            ? Icons.calendar_today_outlined
                            : widget.dataApprover.requestData!.first.leaveType ==
                                    'casualLeave'
                                ? Icons.beach_access_outlined
                                : widget.dataApprover.requestType == 'loanRequest'
                                    ? Icons.payments_outlined
                                    : Icons.description_outlined,
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
                        fontWeight: FontWeight.bold,
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
                        image: AssetImage('images/DP.png'),
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
                          alignment: Alignment.topLeft,
                          child: Text(
                            "${widget.dataApprover.employeeName}",
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            _translateRequestSubtype2(
                                widget.dataApprover.subType != null
                                    ? widget.dataApprover.subType!
                                        .replaceAllMapped(
                                          RegExp(r'([a-z])([A-Z])'),
                                          (Match match) =>
                                              '${match.group(1)} ${match.group(2)}',
                                        )
                                        .replaceFirst(
                                            widget.dataApprover.subType![0],
                                            widget.dataApprover.subType![0]
                                                .toUpperCase())
                                    : '',
                                context),
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
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: _getColorForVerificationStatus(
                          widget.dataApprover.status ?? 'default'),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        _translateStatus(widget.dataApprover.status, context),
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
                      alignment: Alignment.topLeft,
                      child: Text(
                        "${AppLocalizations.of(context)!.duration}:",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      )),
                  const SizedBox(width: 5),
                  Align(
                    alignment: Alignment.topLeft,
                    child: widget.dataApprover.requestType == "loanRequest"
                        ? Text(
                            widget.dataApprover.requestData != null &&
                                    widget.dataApprover.requestData!.isNotEmpty
                                ? "${widget.dataApprover.requestData!.first.loanDuration ?? "---"} ${AppLocalizations.of(context)!.month}"
                                : AppLocalizations.of(context)!.noData,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          )
                        : Text(
                            widget.dataApprover.requestData != null &&
                                    widget.dataApprover.requestData!.isNotEmpty
                                ? "${widget.dataApprover.requestData!.first.startDate ?? "---"} - $daysDiff ${AppLocalizations.of(context)!.days} "
                                : AppLocalizations.of(context)!.noData,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
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
                    "${AppLocalizations.of(context)!.note}:",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(width: 5),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "${widget.dataApprover.reason}",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
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
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '${widget.dataApprover.requestType}',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              if (widget.dataApprover.requestType == 'loanRequest') ...[
                Row(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "${AppLocalizations.of(context)!.totalLoanAmount} - ",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
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
                Row(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "${AppLocalizations.of(context)!.loanInstallment} - ",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
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
                              ? "${widget.dataApprover.requestData!.first.loanInstallment}"
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
                      alignment: Alignment.topLeft,
                      child: Text(
                        "${AppLocalizations.of(context)!.loanCycle} - ",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
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
                              ? "${widget.dataApprover.requestData!.first.loanCycle}"
                              : AppLocalizations.of(context)!.noData,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 20),
              ],
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
                                color: NasColors.onTime,
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

                    // Line after Req
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Container(
                        width: 40,
                        height: 2,
                        color: Colors.grey,
                      ),
                    ),
                    ...[
                      if (widget.dataApprover.approvers != null &&
                          widget.dataApprover.approvers!.isNotEmpty)
                        for (int i = 0;
                            i < widget.dataApprover.approvers!.length;
                            i++) ...[
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
                                      color: _getColorForApproverStatus(widget
                                          .dataApprover.approvers![i].status),
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
                                widget.dataApprover.approvers![i].approverName ??
                                    '---',
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
                    // Line before CEO
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Container(
                        width: 40,
                        height: 2,
                        color: Colors.grey,
                      ),
                    ),
                    // CEO
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
                                color: allApproved
                                    ? NasColors.onTime
                                    : NasColors.pending,
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    "${AppLocalizations.of(context)!.attachment}:",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              /// ✅ Show attachment if exists
              (widget.dataApprover.attachments != null &&
                  widget.dataApprover.attachments!.isNotEmpty)
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
                          final url = widget.dataApprover.attachments!
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
                                  "${widget.dataApprover.attachments!.first.fileName}",
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
                                "${widget.dataApprover.attachments!.first.fileName}",
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
                      fontWeight: FontWeight.bold,
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
            if(isLoading)
              Loader()
          ]
        ),
      ),
      bottomNavigationBar: (widget.dataApprover.approvers != null &&
              widget.dataApprover.approvers!.any(
                (approver) =>
                    approver.approverId ==
                        singletonClass.getJWTModel()?.employeeId &&
                    approver.status == 'pending',
              ))
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              title: Text(
                                AppLocalizations.of(context)!.comment,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: NasColors.darkBlue,
                                  fontSize: 23,
                                ),
                              ),
                              content: SingleChildScrollView(
                                // 🔧 Fixes overflow
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(
                                      color: NasColors.darkBlue,
                                      width: 1.0,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.white,
                                        blurRadius: 15,
                                        offset: Offset(0.10, 10.0),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    textAlign: TextAlign.center,
                                    controller: _comment,
                                    minLines: 1,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: NasColors.darkBlue),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: NasColors.darkBlue),
                                      ),
                                    ),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                    autofocus: false,
                                    textInputAction: TextInputAction.done,
                                    cursorColor: Colors.black,
                                    onTapOutside: (event) {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                  ),
                                ),
                              ),
                              actions: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          patchRequestData(
                                              widget.dataApprover.id,
                                              'rejected',
                                              widget.dataApprover.toJson());
                                          _comment.clear();
                                        },
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .rejected,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          });
                    },
                    child: Container(
                      height: 60,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF4D4D4D),
                            Color(0xFFE64545),
                            Color(0xFFCF3E3E),
                            Color(0xFFC13A3A),
                            Color(0xFF992E2E),
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            title: Text(
                              AppLocalizations.of(context)!.comment,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: NasColors.darkBlue,
                                fontSize: 23,
                              ),
                            ),
                            content: SingleChildScrollView(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: NasColors.darkBlue,
                                    width: 1.0,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.white,
                                      blurRadius: 15,
                                      offset: Offset(0.10, 10.0),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  controller: _comment,
                                  minLines: 1,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: NasColors.darkBlue),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: NasColors.darkBlue),
                                    ),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                  autofocus: false,
                                  textInputAction: TextInputAction.done,
                                  cursorColor: Colors.black,
                                  onTapOutside: (event) {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                ),
                              ),
                            ),
                            actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: NasColors.completed,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        patchRequestData(widget.dataApprover.id,
                                            'approved',
                                            widget.dataApprover.toJson());
                                        _comment.clear();
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.accept,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 60,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF47734D),
                            Color(0xFF5B9362),
                            Color(0xFF66A56E),
                            Color(0xFF76BE7F),
                            Color(0xFF86D991),
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          AppLocalizations.of(context)!.acceptRequest,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
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
    } else {
      return NasColors.completed;
    }
  }

  ///PATCH API CALL
  void patchRequestData(String? requestID, String status,
      Map<String, dynamic> requestData) async {
    String? employeeId = requestData['employeeId'];
    String url = '${singletonClass.baseURL}/request/acceptLeave/$employeeId/$requestID';

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
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => MainScreen(index: 2 , selectedIndex: 1,)));
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
}
