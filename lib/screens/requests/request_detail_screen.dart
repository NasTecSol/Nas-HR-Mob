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
import 'package:pdf/pdf.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../request_controller/approver_request_data_model.dart';
import 'package:flutter/foundation.dart';
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Widget _buildHeader(BuildContext context, AppLocalizations? localizations) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [NasColors.darkBlue, NasColors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: NasColors.darkBlue.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  localizations?.approvals ?? 'Approvals',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => printPdf(),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.print_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    String formatDate(String? updatedAt) {
      if (updatedAt == null || updatedAt.isEmpty) {
        return '---';
      }
      DateTime updatedAtDateTime = (DateTime.tryParse(updatedAt) ?? DateTime.fromMillisecondsSinceEpoch(0));
      return DateFormat('dd-MM-yyyy hh:mm a').format(updatedAtDateTime);
    }

    String getSubtypeText(String? subType) {
      if (subType == null || subType.isEmpty) {
        return '';
      }
      final splitString = subType.replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'),
        (Match match) => '${match.group(1)} ${match.group(2)}',
      );
      if (splitString.isEmpty) return '';
      return splitString.replaceFirst(splitString[0], splitString[0].toUpperCase());
    }

    String date = formatDate(widget.dataApprover.createdAt);
    final approvers = widget.dataApprover.approvers ?? [];
    final approversWithComments = approvers.where((a) => (a.comments?.trim().isNotEmpty ?? false)).toList();

    final allApproved = approvers.isNotEmpty &&
        approvers.every((approver) => approver.status?.toLowerCase() == 'approved');
    final allRejected = approvers.isNotEmpty &&
        approvers.every((approver) => approver.status?.toLowerCase() == 'rejected');
    
    final currentStatus = allApproved ? "approved" : allRejected ? "rejected" : "pending";

    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, localizations),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildSummaryCard(context, date, currentStatus, getSubtypeText(widget.dataApprover.subType)),
                      const SizedBox(height: 16),
                      _buildDetailsCard(context),
                      const SizedBox(height: 16),
                      _buildApprovalFlowCard(context, allApproved, allRejected),
                      const SizedBox(height: 16),
                      _buildCommentsCard(context, approversWithComments),
                      const SizedBox(height: 16),
                      _buildAttachmentsCard(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isLoading)
            const Center(child: Loader()),
        ],
      ),
      bottomNavigationBar: (widget.dataApprover.approvers != null &&
              widget.dataApprover.approvers!.any(
                (approver) =>
                    approver.approverId == singletonClass.getJWTModel()?.employeeId &&
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
                              localizations?.comment ?? 'Comment',
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
                                      borderSide: BorderSide(color: NasColors.darkBlue),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: NasColors.darkBlue),
                                    ),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                  autofocus: false,
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.text,
                                  cursorColor: Colors.black,
                                  onTapOutside: (event) {
                                    FocusManager.instance.primaryFocus?.unfocus();
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
                                      },
                                      child: Text(
                                        localizations?.rejected ?? 'Rejected',
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
                          localizations?.cancel ?? 'Cancel',
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
                              localizations?.comment ?? 'Comment',
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
                                      borderSide: BorderSide(color: NasColors.darkBlue),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: NasColors.darkBlue),
                                    ),
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                  autofocus: false,
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.text,
                                  cursorColor: Colors.black,
                                  onTapOutside: (event) {
                                    FocusManager.instance.primaryFocus?.unfocus();
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
                                        patchRequestData(
                                            widget.dataApprover.id,
                                            'approved',
                                            widget.dataApprover.toJson());
                                      },
                                      child: Text(
                                        localizations?.accept ?? 'Accept',
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
                          localizations?.acceptRequest ?? 'Accept Request',
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

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: NasColors.darkBlue, size: 18),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String date, String status, String subTypeFormatted) {
    final localizations = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  image: const DecorationImage(
                    image: AssetImage('images/DP.png'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.dataApprover.employeeName ?? '---',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _translateRequestSubtype2(subTypeFormatted, context),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getColorForVerificationStatus(status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _translateStatus(status, context),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: _getColorForVerificationStatus(status),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                '${localizations?.createdDate ?? "Created Date"}:',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                date,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    final fields = _getRequestDetailFields(context);
    final localizations = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations?.requests ?? 'Requests',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: NasColors.darkBlue,
            ),
          ),
          const SizedBox(height: 12),
          if (fields.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                localizations?.noData ?? '---',
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            )
          else
            ...fields.map((f) => _buildDetailRow(f['icon'], f['label'], f['value'])),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: NasColors.darkBlue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: NasColors.darkBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalFlowCard(BuildContext context, bool allApproved, bool allRejected) {
    final approvers = widget.dataApprover.approvers ?? [];
    final localizations = AppLocalizations.of(context);
    final flowItems = <Widget>[];

    // Start circle
    flowItems.add(
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
          const SizedBox(height: 5),
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
    );

    // Initial connector line
    flowItems.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Container(
          width: 40,
          height: 2,
          color: Colors.grey,
        ),
      ),
    );

    if (approvers.isNotEmpty) {
      for (int i = 0; i < approvers.length; i++) {
        final approver = approvers[i];
        flowItems.add(
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
                      color: _getColorForApproverStatus(approver.status),
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
                approver.approverName ?? '---',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );

        if (i != approvers.length - 1) {
          flowItems.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Container(
                width: 40,
                height: 2,
                color: Colors.grey,
              ),
            ),
          );
        }
      }
    } else {
      flowItems.add(
        Text(
          '---',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    // Connector to end circle
    flowItems.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Container(
          width: 40,
          height: 2,
          color: Colors.grey,
        ),
      ),
    );

    // End circle
    flowItems.add(
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
                      ? NasColors.completed
                      : allRejected
                          ? Colors.red
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
          const SizedBox(height: 5),
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
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations?.approvals ?? 'Approvals',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: NasColors.darkBlue,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: flowItems,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsCard(BuildContext context, List<Approvers> approversWithComments) {
    final localizations = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations?.comments ?? 'Comments',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: NasColors.darkBlue,
            ),
          ),
          const SizedBox(height: 12),
          if (approversWithComments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "---",
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
              ),
            )
          else
            ...approversWithComments.map((c) {
              final formattedTime = c.timeStamps != null ? singletonClass.formatDate2(c.timeStamps.toString(), context) : '---';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_rounded, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "${c.approverName ?? '---'} • $formattedTime",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c.comments ?? "---",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAttachmentsCard(BuildContext context) {
    final hasAttachment = widget.dataApprover.attachments != null &&
        widget.dataApprover.attachments!.isNotEmpty &&
        widget.dataApprover.attachments!.first.url != null &&
        widget.dataApprover.attachments!.first.url!.isNotEmpty;
    final localizations = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations?.attachment ?? 'Attachment',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: NasColors.darkBlue,
            ),
          ),
          const SizedBox(height: 12),
          if (hasAttachment)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.insert_drive_file_rounded, color: Colors.blueAccent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final url = widget.dataApprover.attachments!.first.url;
                        if (url != null && url.isNotEmpty) {
                          final inlineExtensions = [
                            '.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx',
                            '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.heic',
                            '.heif', '.tiff'
                          ];
                          final lower = url.toLowerCase();
                          final isDocs = inlineExtensions.any((ext) => lower.endsWith(ext));
                          if (isDocs) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FileViewerScreen(
                                  url: url,
                                  fileName: widget.dataApprover.attachments!.first.type ?? 'Document',
                                ),
                              ),
                            );
                          } else {
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                            }
                          }
                        }
                      },
                      child: Text(
                        widget.dataApprover.attachments!.first.type ?? 'Document',
                        style: GoogleFonts.inter(
                          color: Colors.blueAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final url = widget.dataApprover.attachments!.first.url;
                      if (url != null && url.isNotEmpty) {
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                        }
                      }
                    },
                    icon: const Icon(Icons.download_rounded, color: Colors.blueAccent, size: 20),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                localizations?.noData ?? '---',
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getRequestDetailFields(BuildContext context) {
    final fields = <Map<String, dynamic>>[];
    final reqType = widget.dataApprover.requestType;
    final data = widget.dataApprover.requestData != null && widget.dataApprover.requestData!.isNotEmpty
        ? widget.dataApprover.requestData!.first
        : null;

    if (data == null) return fields;

    final localizations = AppLocalizations.of(context);

    if (reqType == 'allowanceIncrement' || reqType == 'allowance_Increment') {
      fields.add({
        'label': localizations?.date ?? 'Date',
        'value': data.effectiveDate != null ? singletonClass.formatDate2(data.effectiveDate.toString(), context) : '---',
        'icon': Icons.calendar_today_rounded,
      });
      fields.add({
        'label': localizations?.days ?? 'Days',
        'value': data.days?.toString() ?? '---',
        'icon': Icons.calendar_month_rounded,
      });
      fields.add({
        'label': localizations?.amount ?? 'Amount',
        'value': data.amount?.toString() ?? '---',
        'icon': Icons.payments_rounded,
      });
      fields.add({
        'label': localizations?.note ?? 'Note',
        'value': (widget.dataApprover.reason != null && widget.dataApprover.reason!.isNotEmpty) ? widget.dataApprover.reason : '---',
        'icon': Icons.description_rounded,
      });
    } else if (reqType == 'overTimeRequest') {
      fields.add({
        'label': localizations?.date ?? 'Date',
        'value': data.date != null ? singletonClass.formatDate2(data.date.toString(), context) : '---',
        'icon': Icons.calendar_today_rounded,
      });
      fields.add({
        'label': localizations?.overTime ?? 'Overtime',
        'value': data.overTimeHours != null ? "${data.overTimeHours} ${localizations?.h ?? 'h'}" : '---',
        'icon': Icons.access_time_rounded,
      });
      if (data.paidAs != null) {
        fields.add({
          'label': "${localizations?.paidAs ?? 'Paid As'} (${localizations?.type ?? 'Type'})",
          'value': data.paidAs!["type"] ?? '---',
          'icon': Icons.payment_rounded,
        });
        fields.add({
          'label': "${localizations?.paidAs ?? 'Paid As'} (${localizations?.amount ?? 'Amount'})",
          'value': data.paidAs!["amount"]?.toString() ?? '---',
          'icon': Icons.payments_rounded,
        });
        fields.add({
          'label': "${localizations?.paidAs ?? 'Paid As'} (${localizations?.totalAmount ?? 'Total Amount'})",
          'value': data.paidAs!["totalAmount"]?.toString() ?? '---',
          'icon': Icons.monetization_on_rounded,
        });
      }
      fields.add({
        'label': localizations?.note ?? 'Note',
        'value': widget.dataApprover.reason ?? '---',
        'icon': Icons.note_rounded,
      });
    } else if (reqType == 'loanRequest') {
      fields.add({
        'label': localizations?.totalLoanAmount ?? 'Total Loan Amount',
        'value': data.loanAmount?.toString() ?? '---',
        'icon': Icons.payments_rounded,
      });
      fields.add({
        'label': localizations?.loanInstallment ?? 'Loan Installment',
        'value': data.loanInstallment?.toString() ?? '---',
        'icon': Icons.receipt_long_rounded,
      });
      fields.add({
        'label': localizations?.loanCycle ?? 'Loan Cycle',
        'value': data.loanCycle?.toString() ?? '---',
        'icon': Icons.repeat_rounded,
      });
      fields.add({
        'label': localizations?.duration ?? 'Duration',
        'value': data.loanDuration != null ? "${data.loanDuration} ${localizations?.month ?? 'month'}" : '---',
        'icon': Icons.timer_rounded,
      });
      fields.add({
        'label': localizations?.note ?? 'Note',
        'value': widget.dataApprover.reason ?? '---',
        'icon': Icons.description_rounded,
      });
    } else if (reqType == 'attendanceRequest') {
      fields.add({
        'label': localizations?.date ?? 'Date',
        'value': data.attendanceDate != null ? singletonClass.formatDate2(data.attendanceDate.toString(), context) : '---',
        'icon': Icons.calendar_today_rounded,
      });
      fields.add({
        'label': localizations?.time ?? 'Time',
        'value': data.attendanceTime != null ? singletonClass.formatDateTime(data.attendanceTime.toString()) : '---',
        'icon': Icons.access_time_rounded,
      });
      fields.add({
        'label': localizations?.type ?? 'Type',
        'value': data.punchingType?.toString() ?? '---',
        'icon': Icons.fingerprint_rounded,
      });
      fields.add({
        'label': localizations?.note ?? 'Note',
        'value': widget.dataApprover.reason ?? '---',
        'icon': Icons.description_rounded,
      });
    } else if (reqType == 'expenseRequest') {
      fields.add({
        'label': "${localizations?.expense ?? 'Expense'} ${localizations?.date ?? 'Date'}",
        'value': data.expenseDate != null ? singletonClass.formatDate2(data.expenseDate.toString(), context) : '---',
        'icon': Icons.calendar_today_rounded,
      });
      fields.add({
        'label': localizations?.amount ?? 'Amount',
        'value': data.amount?.toString() ?? '---',
        'icon': Icons.payments_rounded,
      });
      fields.add({
        'label': localizations?.purpose ?? 'Purpose',
        'value': data.purpose?.toString() ?? '---',
        'icon': Icons.description_rounded,
      });
      fields.add({
        'label': localizations?.category ?? 'Category',
        'value': data.category?.toString() ?? '---',
        'icon': Icons.category_rounded,
      });
      fields.add({
        'label': localizations?.paymentMethods ?? 'Payment Methods',
        'value': data.paymentMethod?.toString() ?? '---',
        'icon': Icons.payment_rounded,
      });
      fields.add({
        'label': localizations?.transactionType ?? 'Transaction Type',
        'value': data.transactionType?.toString() ?? '---',
        'icon': Icons.swap_horiz_rounded,
      });
      fields.add({
        'label': localizations?.note ?? 'Note',
        'value': widget.dataApprover.reason ?? '---',
        'icon': Icons.note_rounded,
      });
    } else if (reqType == 'documentRequest') {
      fields.add({
        'label': localizations?.date ?? 'Date',
        'value': data.date != null ? singletonClass.formatDate2(data.date.toString(), context) : '---',
        'icon': Icons.calendar_today_rounded,
      });
      fields.add({
        'label': "${localizations?.document ?? 'Document'} ${localizations?.type ?? 'Type'}",
        'value': data.documentType?.toString() ?? '---',
        'icon': Icons.file_present_rounded,
      });
      fields.add({
        'label': "${localizations?.document ?? 'Document'} ${localizations?.name ?? 'Name'}",
        'value': data.documentName?.toString() ?? '---',
        'icon': Icons.badge_rounded,
      });
      fields.add({
        'label': localizations?.note ?? 'Note',
        'value': widget.dataApprover.reason ?? '---',
        'icon': Icons.note_rounded,
      });
    } else if (reqType == 'leaveRequest') {
      fields.add({
        'label': localizations?.leaveType ?? 'Leave Type',
        'value': data.leaveType?.toString() ?? '---',
        'icon': Icons.beach_access_rounded,
      });
      fields.add({
        'label': localizations?.startDate ?? 'Start Date',
        'value': data.startDate != null ? singletonClass.formatDate2(data.startDate.toString(), context) : '---',
        'icon': Icons.date_range_rounded,
      });
      fields.add({
        'label': localizations?.endDate ?? 'End Date',
        'value': data.endDate != null ? singletonClass.formatDate2(data.endDate.toString(), context) : '---',
        'icon': Icons.date_range_rounded,
      });
      fields.add({
        'label': localizations?.note ?? 'Note',
        'value': widget.dataApprover.reason ?? '---',
        'icon': Icons.description_rounded,
      });
    } else if (reqType == 'specialLeaveRequest') {
      fields.add({
        'label': localizations?.leaveType ?? 'Leave Type',
        'value': data.leaveType?.toString() ?? '---',
        'icon': Icons.beach_access_rounded,
      });
      fields.add({
        'label': localizations?.startDate ?? 'Start Date',
        'value': data.startDate != null ? singletonClass.formatDate2(data.startDate.toString(), context) : '---',
        'icon': Icons.date_range_rounded,
      });
      fields.add({
        'label': localizations?.endDate ?? 'End Date',
        'value': data.endDate != null ? singletonClass.formatDate2(data.endDate.toString(), context) : '---',
        'icon': Icons.date_range_rounded,
      });
      fields.add({
        'label': localizations?.days ?? 'Days',
        'value': data.days?.toString() ?? '---',
        'icon': Icons.timer_rounded,
      });
    } else if (reqType == 'remoteRequest') {
      fields.add({
        'label': localizations?.startDate ?? 'Start Date',
        'value': data.startDate != null ? singletonClass.formatDate2(data.startDate.toString(), context) : '---',
        'icon': Icons.date_range_rounded,
      });
      fields.add({
        'label': localizations?.endDate ?? 'End Date',
        'value': data.endDate != null ? singletonClass.formatDate2(data.endDate.toString(), context) : '---',
        'icon': Icons.date_range_rounded,
      });
      fields.add({
        'label': localizations?.note ?? 'Note',
        'value': widget.dataApprover.reason ?? '---',
        'icon': Icons.description_rounded,
      });
    } else if (reqType == 'resignationRequest') {
      fields.add({
        'label': localizations?.date ?? 'Date',
        'value': data.date != null ? singletonClass.formatDate2(data.date.toString(), context) : '---',
        'icon': Icons.calendar_today_rounded,
      });
      fields.add({
        'label': localizations?.note ?? 'Note',
        'value': widget.dataApprover.reason ?? '---',
        'icon': Icons.description_rounded,
      });
    } else if (reqType == 'complaintRequest') {
      fields.add({
        'label': localizations?.subject ?? 'Subject',
        'value': widget.dataApprover.reason ?? '---',
        'icon': Icons.feedback_rounded,
      });
    }

    return fields;
  }

  String _translateRequestSubtype2(String? status, BuildContext context) {
    if (status == null || status.isEmpty) {
      return '---';
    }
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return status;
    }
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
        return status;
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
    if (status == null || status.isEmpty) {
      return '---';
    }
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return status;
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
    } else if (approverStatus == "rejected") {
      return Colors.red;
    } else {
      return NasColors.completed;
    }
  }

  ///PATCH API CALL
  void patchRequestData(String? requestID, String status, Map<String, dynamic> requestData) async {
    String? employeeId = requestData['employeeId'];
    if (employeeId == null || requestID == null) {
      debugPrint("Invalid employeeId or requestID for PATCH call.");
      return;
    }
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
        if (mounted) {
          await QuickAlert.show(
            autoCloseDuration: const Duration(seconds: 2),
            showCancelBtn: false,
            showConfirmBtn: false,
            context: context,
            title: AppLocalizations.of(context)?.success ?? 'Success',
            type: QuickAlertType.success,
          );
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MainScreen(
                        index: 2,
                        selectedIndex: 1,
                        showBanner: false,
                      )));
        }
      } else {
        if (mounted) {
          await QuickAlert.show(
            autoCloseDuration: const Duration(seconds: 2),
            showCancelBtn: false,
            showConfirmBtn: false,
            context: context,
            title: AppLocalizations.of(context)?.internalServerError ?? 'Internal Server Error',
            type: QuickAlertType.error,
          );
        }
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Failed to send data. Error: $error');
      if (mounted) {
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

  ///PDF generate methods
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
    final t = AppLocalizations.of(context);
    List approversWithComments = [];
    if (data.approvers != null) approversWithComments = data.approvers!.where((a) => a.comments != null && a.comments!.isNotEmpty).toList();
    if (approversWithComments.isEmpty) return '<div style="margin: 20px 0;"><h3 style="margin-bottom: 15px;">${t?.comments ?? 'Comments'}</h3><p>Not Available</p></div>';
    String commentsHtml = '';
    for (var comment in approversWithComments) {
      final name = comment.approverName ?? '---';
      final timestamp = comment.timeStamps != null ? singletonClass.formatDate2(comment.timeStamps.toString(), context) : '---';
      final commentText = comment.comments ?? '---';
      commentsHtml += '<div style="background-color: #f5f5f5; border-radius: 8px; padding: 10px; margin-bottom: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);"><p style="font-size: 13px; font-weight: bold; margin: 0 0 10px 0; color: black;">$name • $timestamp</p><p style="font-size: 15px; color: black; margin: 0;">$commentText</p></div>';
    }
    return '<div style="margin: 20px 0;"><h3 style="margin-bottom: 15px;">${t?.comments ?? 'Comments'}</h3>$commentsHtml</div>';
  }

  String buildHtmlContent() {
    try {
      final t = AppLocalizations.of(context);
      final data = widget.dataApprover;
      String content = '';

      final dateLabel = t?.date ?? 'Date';
      final amountLabel = t?.amount ?? 'Amount';
      final noteLabel = t?.note ?? 'Note';
      final noDataLabel = t?.noData ?? '---';
      final overTimeLabel = t?.overTime ?? 'Overtime';
      final hLabel = t?.h ?? 'h';
      final paidAsLabel = t?.paidAs ?? 'Paid As';
      final typeLabel = t?.type ?? 'Type';
      final totalAmountLabel = t?.totalAmount ?? 'Total Amount';
      final durationLabel = t?.duration ?? 'Duration';
      final monthLabel = t?.month ?? 'month';
      final totalLoanAmountLabel = t?.totalLoanAmount ?? 'Total Loan Amount';
      final loanInstallmentLabel = t?.loanInstallment ?? 'Loan Installment';
      final loanCycleLabel = t?.loanCycle ?? 'Loan Cycle';
      final timeLabel = t?.time ?? 'Time';
      final expenseLabel = t?.expense ?? 'Expense';
      final purposeLabel = t?.purpose ?? 'Purpose';
      final categoryLabel = t?.category ?? 'Category';
      final paymentMethodsLabel = t?.paymentMethods ?? 'Payment Methods';
      final transactionTypeLabel = t?.transactionType ?? 'Transaction Type';
      final documentLabel = t?.document ?? 'Document';
      final nameLabel = t?.name ?? 'Name';
      final daysLabel = t?.days ?? 'days';

      if (data.requestType == 'allowanceIncrement') {
        content += htmlRow(dateLabel, data.requestData != null && data.requestData!.isNotEmpty ? singletonClass.formatDate2(data.requestData!.first.date, context) : noDataLabel);
        content += htmlRow(amountLabel, data.requestData != null && data.requestData!.isNotEmpty ? "${data.requestData!.first.amount ?? '---'}" : noDataLabel);
        content += htmlRow(noteLabel, data.reason ?? '---');
        content += htmlRow('Request Type', data.requestType ?? '---');
      } else if (data.requestType == 'overTimeRequest') {
        content += htmlRow(dateLabel, data.requestData != null && data.requestData!.isNotEmpty ? singletonClass.formatDate2(data.requestData!.first.date, context) : noDataLabel);
        content += htmlRow(overTimeLabel, data.requestData != null && data.requestData!.isNotEmpty ? "${data.requestData!.first.overTimeHours ?? '---'} $hLabel" : noDataLabel);
        if (data.requestData != null && data.requestData!.isNotEmpty && data.requestData!.first.paidAs != null) {
          final paidAs = data.requestData!.first.paidAs!;
          content += '<div style="margin: 15px 0;"><strong>$paidAsLabel:</strong></div>';
          content += htmlRow(typeLabel, paidAs['type']?.toString() ?? '---');
          content += htmlRow(amountLabel, paidAs['amount']?.toString() ?? '---');
          content += htmlRow(totalAmountLabel, paidAs['totalAmount']?.toString() ?? '---');
        }
        content += htmlRow(noteLabel, data.reason ?? '---');
        content += htmlRow('Request Type', data.requestType ?? '---');
      } else if (data.requestType == 'loanRequest') {
        final r = data.requestData?.first;
        content += htmlRow(durationLabel, r != null ? "${r.loanDuration ?? '---'} $monthLabel" : '---');
        content += htmlRow(totalLoanAmountLabel, r?.loanAmount?.toString() ?? '---');
        content += htmlRow(loanInstallmentLabel, r?.loanInstallment?.toString() ?? '---');
        content += htmlRow(loanCycleLabel, r?.loanCycle ?? '---');
        content += htmlRow(noteLabel, data.reason ?? '---');
        content += htmlRow('Request Type', data.requestType ?? '---');
      } else if (data.requestType == 'attendanceRequest') {
        final r = data.requestData?.first;
        content += htmlRow(dateLabel, r != null ? singletonClass.formatDate2(r.attendanceDate, context) : '---');
        content += htmlRow(timeLabel, r?.attendanceTime ?? '---');
        content += htmlRow(typeLabel, r?.punchingType ?? '---');
        content += htmlRow(noteLabel, data.reason ?? '---');
        content += htmlRow('Request Type', data.requestType ?? '---');
      } else if (data.requestType == 'expenseRequest') {
        final r = data.requestData?.first;
        content += htmlRow('$expenseLabel $dateLabel', r != null ? singletonClass.formatDate2(r.expenseDate, context) : '---');
        content += htmlRow(amountLabel, r?.amount?.toString() ?? '---');
        content += htmlRow(purposeLabel, r?.purpose ?? '---');
        content += htmlRow(categoryLabel, r?.category ?? '---');
        content += htmlRow(paymentMethodsLabel, r?.paymentMethod ?? '---');
        content += htmlRow(transactionTypeLabel, r?.transactionType ?? '---');
        content += htmlRow(noteLabel, data.reason ?? '---');
        content += htmlRow('Request Type', data.requestType ?? '---');
      } else if (data.requestType == 'documentRequest') {
        final r = data.requestData?.first;
        content += htmlRow(dateLabel, r != null && r.date != null ? singletonClass.formatDate2(r.date!, context) : noDataLabel);
        content += htmlRow('$documentLabel $typeLabel', r?.documentType ?? '---');
        content += htmlRow('$documentLabel $nameLabel', r?.documentName ?? '---');
        content += htmlRow(noteLabel, data.reason ?? '---');
        content += htmlRow('Request Type', data.requestType ?? '---');
      } else if (data.requestType == 'leaveRequest') {
        final r = data.requestData?.first;
        if (data.subType == 'shortLeave') {
          content += htmlRow(dateLabel, r != null ? singletonClass.formatDate2(r.startDate, context) : noDataLabel);
          content += htmlRow(timeLabel, r != null ? "${singletonClass.formatDateTime(r.startDate)} - ${singletonClass.formatDateTime(r.endDate)}" : noDataLabel);
          content += htmlRow(durationLabel, r != null ? "${r.duration ?? '---'} $hLabel" : '---');
        } else {
          content += htmlRow(dateLabel, r != null ? "${singletonClass.formatDate2(r.startDate, context)} - ${singletonClass.formatDate2(r.endDate, context)}" : noDataLabel);
          content += htmlRow(durationLabel, r != null ? "${r.duration ?? '---'} $daysLabel" : '---');
        }
        content += htmlRow(noteLabel, data.reason ?? '---');
        content += htmlRow('Request Type', data.requestType ?? '---');
      } else if (data.requestType == 'specialLeaveRequest') {
        final r = data.requestData?.first;
        content += htmlRow(dateLabel, r != null ? "${singletonClass.formatDate2(r.startDate, context)} - ${singletonClass.formatDate2(r.endDate, context)}" : noDataLabel);
        content += htmlRow(durationLabel, r != null ? "${r.duration ?? '---'} $daysLabel" : '---');
        content += htmlRow(noteLabel, data.reason ?? '---');
        content += htmlRow('Request Type', data.requestType ?? '---');
      } else {
        content += htmlRow('Request Type', data.requestType ?? 'Unknown');
        content += htmlRow(noteLabel, data.reason ?? '---');
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

      String headerImgTag = '';
      String footerImgTag = '';

      try {
        final headerBytes = await _fetchImageAsBase64(headerUrl);
        headerImgTag = '<img class="header-img" src="data:image/png;base64,$headerBytes" alt="Header"/>';
      } catch (_) {
        headerImgTag = '';
      }

      try {
        final footerBytes = await _fetchImageAsBase64(footerUrl);
        footerImgTag = '<img class="footer-img" src="data:image/png;base64,$footerBytes" alt="Footer"/>';
      } catch (_) {
        footerImgTag = '';
      }

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
    $headerImgTag
    <div class="content">$body</div>
    $approversWorkflow
    $commentsSection
    $footerImgTag
  </body>
</html>
''';
    } catch (e) {
      if (kDebugMode) print('Error generating HTML: $e');
      rethrow;
    }
  }

  Future<String> _fetchImageAsBase64(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return base64Encode(response.bodyBytes);
    }
    throw Exception('Failed to load image: $url');
  }

  Future<void> printPdf() async {
    try {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(child: Loader()),
        );
      }

      final html = await generateFullHtml(
        headerUrl: singletonClass.headerUrl,
        footerUrl: singletonClass.footerUrl,
      );

      final pdfBytes = await Printing.convertHtml(
        format: PdfPageFormat.a4,
        html: html,
        baseUrl: 'about:blank',
      );

      if (kDebugMode) print('PDF bytes length: ${pdfBytes.length}');

      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      if (mounted) {
        showModalBottomSheet(
          context: context,
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.print, color: Colors.black),
                  title: Text(
                    AppLocalizations.of(context)?.print ?? 'Print',
                    style: GoogleFonts.inter(fontSize: 15, color: Colors.black),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await Printing.layoutPdf(
                      name: 'Request_Document',
                      onLayout: (_) async => pdfBytes,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share, color: Colors.blue),
                  title: Text(
                    'Share / Save PDF',
                    style: GoogleFonts.inter(fontSize: 15, color: Colors.blue),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await Printing.sharePdf(
                      bytes: pdfBytes,
                      filename: 'Request_Document.pdf',
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.open_in_new, color: Colors.green),
                  title: Text(
                    'Open',
                    style: GoogleFonts.inter(fontSize: 15, color: Colors.green),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Center(child: Loader()),
                    );

                    final localPath = await _savePdfLocally(pdfBytes);

                    if (mounted) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }

                    if (localPath != null && localPath.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FileViewerScreen(
                            url: localPath,
                            fileName: 'Request_Document',
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to save and open document'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.red),
                  title: Text(
                    AppLocalizations.of(context)?.cancel ?? 'Cancel',
                    style: GoogleFonts.inter(fontSize: 15, color: Colors.red),
                  ),
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      if (mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}
      }
      if (kDebugMode) {
        print('Error printing PDF: $e');
        print('StackTrace: $stackTrace');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _savePdfLocally(Uint8List pdfBytes) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/Request_Document.pdf');
      await file.writeAsBytes(pdfBytes);
      return file.path;
    } catch (e) {
      debugPrint("Error saving PDF locally: $e");
    }
    return null;
  }
}
