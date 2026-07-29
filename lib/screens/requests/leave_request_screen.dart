import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../request_controller/company_model.dart';
import '../../widgets/loader.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../request_controller/company_model.dart' show Request, SubTypes;
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../request_controller/company_model.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../request_controller/attachment_response_model.dart';
import '../main_screen.dart';

class LeaveRequestScreen extends StatefulWidget {
  final Request? selectedRequest;
  const LeaveRequestScreen({super.key, this.selectedRequest});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  bool isLoading = false;
  SingletonClass singletonClass = SingletonClass();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _totalDays = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  SubTypes? _selectedSubType;
  DateTime? startDate;
  DateTime? endDate;
  PlatformFile? selectedFile;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  // Computed — no stored bool needed

  @override
  Widget build(BuildContext context) {
    final List<SubTypes> subTypeList = widget.selectedRequest?.subTypes ?? [];
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Form(
        key: _formKey,
        child: Stack(children: [
          CustomScrollView(
            slivers: [
              // ── Gradient header ──────────────────────────────────────────
              SliverToBoxAdapter(child: _buildHeader(context)),

              // ── Form body ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Leave Type card ──
                      _sectionLabel(AppLocalizations.of(context)!.leaveRequests),
                      const SizedBox(height: 8),
                      _buildLeaveTypeDropdown(context, subTypeList),

                      const SizedBox(height: 20),

                      // ── Date / Time section ──
                      if (_selectedSubType?.requestName == 'Short Leave') ...[
                        _buildShortLeaveFields(context),
                      ] else ...[
                        _buildRegularLeaveFields(context),
                      ],

                      const SizedBox(height: 20),

                      // ── Notes ──
                      _sectionLabel(AppLocalizations.of(context)!.notes),
                      const SizedBox(height: 8),
                      _buildNotesField(context),

                      const SizedBox(height: 20),

                      // ── Attachment ──
                      if (_selectedSubType != null &&
                          _selectedSubType!.docRequired == true) ...[
                        _buildAttachmentButton(context),
                        const SizedBox(height: 20),
                      ],

                      // ── Submit button ──
                      _buildSubmitButton(context),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isLoading) Loader(),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    // Resolve balance values for the currently selected subtype
    final _BalanceInfo balance = _getLeaveBalanceInfo(_selectedSubType);

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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button row
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
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
                      AppLocalizations.of(context)!.applyRequests,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Request type + balance card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.22)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Request type row ──
                    Row(
                      children: [
                        Container(
                          height: 38,
                          width: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.event_note_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _translateBottomText(
                                    widget.selectedRequest?.requestName,
                                    context),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.70),
                                ),
                              ),
                              Text(
                                _translateRequest(
                                    widget.selectedRequest?.requestName,
                                    context),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // ── Divider ──
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Divider(
                        color: Colors.white.withOpacity(0.2),
                        height: 1,
                      ),
                    ),

                    // ── Balance label row ──
                    Row(
                      children: [
                        Icon(Icons.account_balance_wallet_rounded,
                            color: Colors.white.withOpacity(0.75), size: 15),
                        const SizedBox(width: 6),
                        Text(
                          _selectedSubType == null
                              ? AppLocalizations.of(context)!.leaveBalance
                              : _translateRequestSubtype(
                                  _selectedSubType!.requestName, context),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.75),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ── Balance pills ──
                    if (_selectedSubType == null)
                      Text(
                        AppLocalizations.of(context)!.selectSubType,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.5),
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: _balancePill(
                              label: 'Entitled',
                              value: balance.entitlementLabel,
                              color: Colors.white.withOpacity(0.22),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _balancePill(
                              label: 'Used',
                              value: balance.usedLabel,
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _balancePill(
                              label: 'Remaining',
                              value: balance.remainingLabel,
                              color: balance.hasBalance
                                  ? const Color(0xFF4CAF50).withOpacity(0.35)
                                  : Colors.red.withOpacity(0.35),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Small pill widget used in balance row ──
  Widget _balancePill({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }

  // ── Resolves entitlement / used / remaining for the selected subtype ──
  _BalanceInfo _getLeaveBalanceInfo(SubTypes? subType) {
    if (subType == null || singletonClass.employeeDataList.isEmpty) {
      return _BalanceInfo.empty();
    }

    final leaveBalance =
        singletonClass.employeeDataList.first.data.first.leaveBalance;
    if (leaveBalance == null) return _BalanceInfo.empty();

    final String? name = subType.requestName;
    final String? type = subType.requestType;

    // Short Leave — uses minutes from shortLeavesMonthlyBal
    if (name == 'Short Leave' || name == 'shortLeave') {
      final mins = leaveBalance.shortLeavesMonthlyBal?.shortLeavesMinutes;
      final minsNum = mins is num ? mins.toDouble() : 0.0;
      return _BalanceInfo(
        entitlementLabel: '—',
        usedLabel: '—',
        remainingLabel: '${minsNum.toStringAsFixed(0)}m',
        hasBalance: minsNum > 0,
      );
    }

    // Unpaid Leave — no fixed balance
    if (name == 'UnPaid Leave ' || name == 'unPaidLeave') {
      return _BalanceInfo(
        entitlementLabel: '∞',
        usedLabel: '—',
        remainingLabel: '∞',
        hasBalance: true,
      );
    }

    // Match by requestType key (same logic used in _getRemainingLeaveBalance)
    if (type != null) {
      final json = leaveBalance.toJson();
      for (final entry in json.entries) {
        if (entry.key.toLowerCase() == type.toLowerCase() &&
            entry.value is Map) {
          final map = entry.value as Map;
          final ent = map['entitlement'];
          final used = map['used'];
          final rem = map['remaining'];

          String _fmt(dynamic v) =>
              v is num ? v.toStringAsFixed(1).replaceAll('.0', '') : '—';

          final remNum = rem is num ? rem.toDouble() : 0.0;
          return _BalanceInfo(
            entitlementLabel: _fmt(ent),
            usedLabel: _fmt(used),
            remainingLabel: _fmt(rem),
            hasBalance: remNum > 0,
          );
        }
      }
    }

    return _BalanceInfo.empty();
  }


  // ─────────────────────────────────────────────────────────────────────────
  // SECTION LABEL
  // ─────────────────────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: NasColors.darkBlue,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: NasColors.darkBlue,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LEAVE TYPE DROPDOWN
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLeaveTypeDropdown(BuildContext context, List<SubTypes> subTypeList) {
    return _formCard(
      child: DropdownButtonFormField<SubTypes>(
        dropdownColor: Colors.white,
        value: subTypeList.contains(_selectedSubType) ? _selectedSubType : null,
        isExpanded: true,
        validator: (value) {
          if (value == null) {
            return AppLocalizations.of(context)!.selectSubType;
          }
          return null;
        },
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        ),
        hint: Text(
          _translateRequest(widget.selectedRequest?.requestName, context),
          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500),
        ),
        icon: Icon(Icons.keyboard_arrow_down_rounded,
            color: NasColors.darkBlue, size: 22),
        items: subTypeList.map((SubTypes subType) {
          return DropdownMenuItem<SubTypes>(
            value: subType,
            child: Text(
              _translateRequestSubtype(subType.requestName!, context),
              style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
            ),
          );
        }).toList(),
        onChanged: (SubTypes? newValue) {
          setState(() {
            _selectedSubType = newValue;
          });
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SHORT LEAVE FIELDS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildShortLeaveFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(AppLocalizations.of(context)!.date),
        const SizedBox(height: 8),
        _buildDatePickerTile(
          context: context,
          label: startDate == null
              ? AppLocalizations.of(context)!.selectDate
              : DateFormat('MMM yyyy').format(startDate!),
          icon: Icons.calendar_today_rounded,
          onTap: () async {
            DateTime? date = await _showStyledDatePicker(
                context, startDate ?? DateTime.now());
            if (date != null) {
              setState(() => startDate = date);
              calculateTotalDays();
            }
          },
        ),
        const SizedBox(height: 20),

        _sectionLabel(AppLocalizations.of(context)!.time),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTimeTile(
                context: context,
                label: startTime == null
                    ? AppLocalizations.of(context)!.startTime
                    : startTime!.format(context),
                onTap: () async {
                  final picked = await _showStyledTimePicker(
                      context, startTime ?? TimeOfDay.now());
                  if (picked != null) {
                    setState(() {
                      startTime = picked;
                      updateTotalTime();
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeTile(
                context: context,
                label: endTime == null
                    ? AppLocalizations.of(context)!.endTime
                    : endTime!.format(context),
                onTap: () async {
                  final picked = await _showStyledTimePicker(
                      context, endTime ?? TimeOfDay.now());
                  if (picked != null) {
                    setState(() {
                      endTime = picked;
                      updateTotalTime();
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _sectionLabel(AppLocalizations.of(context)!.totalHours),
        const SizedBox(height: 8),
        _formCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.hourglass_bottom_rounded,
                    color: NasColors.darkBlue, size: 18),
                const SizedBox(width: 10),
                Text(
                  _totalDays.text.isEmpty ? '0h 0m' : _totalDays.text,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _totalDays.text.isEmpty
                        ? Colors.grey.shade400
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REGULAR LEAVE FIELDS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildRegularLeaveFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(AppLocalizations.of(context)!.duration),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDatePickerTile(
                context: context,
                label: startDate == null
                    ? AppLocalizations.of(context)!.selectDate
                    : DateFormat('dd MMM yyyy').format(startDate!),
                icon: Icons.calendar_today_rounded,
                onTap: () async {
                  DateTime? date = await _showStyledDatePicker(
                      context, startDate ?? DateTime.now());
                  if (date != null) {
                    setState(() => startDate = date);
                    calculateTotalDays();
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Container(
                    width: 24,
                    height: 1.5,
                    color: NasColors.darkBlue.withOpacity(0.4),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildDatePickerTile(
                context: context,
                label: endDate == null
                    ? AppLocalizations.of(context)!.selectDate
                    : DateFormat('dd MMM yyyy').format(endDate!),
                icon: Icons.calendar_today_rounded,
                onTap: () async {
                  DateTime? date = await _showStyledDatePicker(
                      context, endDate ?? DateTime.now());
                  if (date != null) {
                    setState(() => endDate = date);
                    calculateTotalDays();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _sectionLabel(AppLocalizations.of(context)!.totalDays),
        const SizedBox(height: 8),
        _formCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.date_range_rounded,
                    color: NasColors.darkBlue, size: 18),
                const SizedBox(width: 10),
                Text(
                  _totalDays.text.isEmpty ? '0' : _totalDays.text,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _totalDays.text.isEmpty
                        ? Colors.grey.shade400
                        : Colors.black87,
                  ),
                ),
                if (_totalDays.text.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context)!.days,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DATE PICKER TILE
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDatePickerTile({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _formCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: NasColors.darkBlue, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: label == AppLocalizations.of(context)!.selectDate
                        ? Colors.grey.shade400
                        : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TIME TILE
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTimeTile({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _formCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.access_time_rounded,
                  color: NasColors.darkBlue, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: (label == AppLocalizations.of(context)!.startTime ||
                            label == AppLocalizations.of(context)!.endTime)
                        ? Colors.grey.shade400
                        : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // NOTES FIELD
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildNotesField(BuildContext context) {
    return _formCard(
      child: TextFormField(
        cursorColor: NasColors.darkBlue,
        controller: _notes,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.text,
        maxLines: 4,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return AppLocalizations.of(context)!.enterNotesValidation;
          }
          return null;
        },
        style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.typeYourDescription,
          hintStyle:
              GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ATTACHMENT BUTTON
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildAttachmentButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        FilePickerResult? result =
            await FilePicker.platform.pickFiles(type: FileType.any);
        if (result != null && result.files.single.path != null) {
          final PlatformFile file = result.files.single;
          setState(() => selectedFile = file);

          final results = await uploadDocuments(file);
          final bool success = results["success"] as bool;
          final String message = results["message"] as String;

          if (!success && context.mounted) {
            setState(() => selectedFile = null);
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: Colors.white,
                title: Text(AppLocalizations.of(context)!.uploadFailedTitle),
                content: Text(message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      AppLocalizations.of(context)!.ok,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: NasColors.darkBlue),
                    ),
                  ),
                ],
              ),
            );
          }
        } else {
          if (kDebugMode) print('File selection canceled.');
        }
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: NasColors.darkBlue.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: NasColors.darkBlue.withOpacity(0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: NasColors.darkBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.attach_file_rounded,
                  color: NasColors.darkBlue, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.attachDocuments,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: NasColors.darkBlue,
                    ),
                  ),
                  if (selectedFile != null)
                    Text(
                      selectedFile!.name,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.grey.shade500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      'Tap to select a file',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.grey.shade400),
                    ),
                ],
              ),
            ),
            if (selectedFile != null)
              GestureDetector(
                onTap: () => setState(() => selectedFile = null),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close,
                      color: Colors.white, size: 14),
                ),
              )
            else
              Icon(Icons.arrow_forward_ios_rounded,
                  color: NasColors.darkBlue.withOpacity(0.5), size: 14),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SUBMIT BUTTON
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSubmitButton(BuildContext context) {
    return Builder(builder: (context) {
      final bool hasSufficientBalance =
          _isBalanceSufficient(_selectedSubType);
      return GestureDetector(
        onTap: hasSufficientBalance
            ? () {
                if (_formKey.currentState!.validate()) {
                  postRequest();
                }
              }
            : () {
                final String leaveName = _selectedSubType != null
                    ? _translateRequestSubtype(
                        _selectedSubType!.requestName, context)
                    : AppLocalizations.of(context)!.leaveRequests;
                final double? balance =
                    _getRemainingLeaveBalance(_selectedSubType?.requestType);
                final String balanceText = balance != null
                    ? '$leaveName: ${balance.toStringAsFixed(1)} ${AppLocalizations.of(context)!.days}'
                    : '${AppLocalizations.of(context)!.insufficient} $leaveName ${AppLocalizations.of(context)!.balance}';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      balanceText,
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                    backgroundColor: Colors.grey[700],
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: hasSufficientBalance
                ? LinearGradient(
                    colors: [NasColors.darkBlue, NasColors.lightBlue],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : LinearGradient(
                    colors: [Colors.grey.shade400, Colors.grey.shade400],
                  ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: hasSufficientBalance
                ? [
                    BoxShadow(
                      color: NasColors.darkBlue.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasSufficientBalance
                    ? Icons.send_rounded
                    : Icons.lock_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.requests,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SHARED FORM CARD WRAPPER
  // ─────────────────────────────────────────────────────────────────────────
  Widget _formCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // THEMED DATE / TIME PICKERS
  // ─────────────────────────────────────────────────────────────────────────
  Future<DateTime?> _showStyledDatePicker(
      BuildContext context, DateTime initial) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext ctx, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: NasColors.darkBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  foregroundColor: NasColors.darkBlue),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<TimeOfDay?> _showStyledTimePicker(
      BuildContext context, TimeOfDay initial) {
    return showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: NasColors.darkBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BALANCE CHECK
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns true when the selected leave type has enough balance to request,
  /// or when balance is not applicable (shortLeave / unPaidLeave / nothing selected yet).
  bool _isBalanceSufficient(SubTypes? subType) {
    if (subType == null) return true; // nothing chosen yet — show enabled
    final String? name = subType.requestName;
    // These types don't consume a counted balance
    if (name == 'shortLeave' ||
        name == 'unPaidLeave' ||
        name == 'Short Leave' ||
        name == 'UnPaid Leave ') {
      return true;
    }
    final double? remaining = _getRemainingLeaveBalance(subType.requestType);
    return remaining != null && remaining > 0;
  }

  ///Helper method to calculate remaining days

  double? _getRemainingLeaveBalance(String? requestName) {
    if (requestName == null) return null;
    var leaveBalance =
        singletonClass.employeeDataList.first.data.first.leaveBalance;
    for (var entry in leaveBalance!.toJson().entries) {
      print('Checking entry: ${entry.key}');
      if (entry.key.toLowerCase() == requestName.toLowerCase()) {
        print('Found entry: ${entry.key}: ${entry.value}');

        if (entry.key == 'unPaidLeave' || entry.key == 'shortLeave') {
          print('No balance check needed for ${entry.key}');
          return null; // or any sentinel value indicating balance not required
        }
        var remaining = entry.value['remaining'];
        print('Remaining for ${entry.key}: $remaining');

        return remaining is num ? remaining.toDouble() : null;
      }
    }
    return null;
  }

  String calculateTotalTime() {
    if (startTime == null || endTime == null) {
      return '0h 0m';
    }

    final startMinutes = startTime!.hour * 60 + startTime!.minute;
    final endMinutes = endTime!.hour * 60 + endTime!.minute;

    if (endMinutes <= startMinutes) {
      return '0h 0m';
    }

    final diffMinutes = endMinutes - startMinutes;
    final hours = diffMinutes ~/ 60;
    final minutes = diffMinutes % 60;

    return '${hours}h ${minutes}m';
  }

  void updateTotalTime() {
    _totalDays.text = calculateTotalTime();
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ).toUtc();
  }

  double _calculateDurationInHours() {
    if (startTime == null || endTime == null) return 0;

    final startMinutes = startTime!.hour * 60 + startTime!.minute;
    final endMinutes = endTime!.hour * 60 + endTime!.minute;

    final diffMinutes = endMinutes - startMinutes;
    return diffMinutes / 60;
  }

  ///Helper  method to calculate total days
  void calculateTotalDays() {
    if (startDate == null || endDate == null) return;
    int days = endDate!.difference(startDate!).inDays + 1;
    if (days < 0) days = 0;
    setState(() {
      _totalDays.text = days.toString();
    });
  }

  /// APi methods
  Future<Map<String, dynamic>> uploadDocuments(PlatformFile file) async {
    try {
      Uint8List fileBytes;
      if (file.bytes != null) {
        fileBytes = file.bytes!;
      } else {
        fileBytes = await File(file.path!).readAsBytes();
      }

      setState(() => isLoading = true);

      final uri = Uri.parse('${singletonClass.baseURL}/s3-bucket/upload');
      final request = http.MultipartRequest('POST', uri);

      final mimeType =
          lookupMimeType(file.path ?? '') ?? 'application/octet-stream';
      request.headers.addAll(singletonClass.getHeaders());
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: file.name,
        contentType: MediaType.parse(mimeType),
      ));

      request.fields['attachmentName'] = file.name;
      request.fields['attachmentType'] = file.extension ?? '';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (mounted) setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final decodedJson = json.decode(responseBody);
        final attachmentResponse = AttachmentResponse.fromJson(decodedJson);
        singletonClass.attachmentResponseDataList.clear();
        singletonClass.attachmentResponseDataList = [attachmentResponse];
        return {"success": true, "message": ""};
      } else {
        return {
          "success": false,
          "message":
              "Upload failed: ${response.statusCode}\n\n$responseBody"
        };
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      return {"success": false, "message": "Error: $e"};
    }
  }

  Future<void> postRequest() async {
    try {
      final jwtModel = singletonClass.getJWTModel();

      final String? employeeId = jwtModel?.employeeId;
      final String? empId = jwtModel?.empId;
      final String? companyId = jwtModel?.companyId;
      final String? branchId = jwtModel?.branchId;

      if (singletonClass.employeeDataList.isEmpty ||
          singletonClass.companyDataList.isEmpty) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: AppLocalizations.of(context)!.employeeOrCompanyMissing,
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
        return;
      }

      final String? firstName =
          singletonClass.employeeDataList.first.data.first.firstName;
      final String? middleName =
          singletonClass.employeeDataList.first.data.first.middleName;
      final String? lastName =
          singletonClass.employeeDataList.first.data.first.lastName;

      final String employeeName = [firstName, middleName, lastName]
          .where((e) => e != null && e.isNotEmpty)
          .join(' ');

      final String? policyId = singletonClass
          .companyDataList.first.data?.policies?.first.policyId;

      final String? selectedRequestType =
          widget.selectedRequest?.requestType;
      final String? selectedSubType = _selectedSubType?.requestType;

      if (selectedRequestType == null || selectedSubType == null) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: AppLocalizations.of(context)!.selectSubType,
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
        return;
      }

      if (startDate == null && endDate == null) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: AppLocalizations.of(context)!.selectDate,
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
        return;
      }

      final List<Map<String, dynamic>> attachments = [];
      if (selectedFile != null) {
        if (singletonClass.attachmentResponseDataList.isNotEmpty &&
            singletonClass
                    .attachmentResponseDataList.first.data !=
                null) {
          attachments.add({
            "type": singletonClass
                .attachmentResponseDataList.first.data!.attachmentType,
            "url": singletonClass
                .attachmentResponseDataList.first.data!.url,
          });
        }
      }
      final bool isShortLeave =
          selectedSubType.toLowerCase() == 'short leave' ||
              selectedSubType.toLowerCase() == 'shortleave';

      final Map<String, dynamic> data = {
        "empId": empId,
        "employeeId": employeeId,
        "employeeName": employeeName,
        "companyId": companyId,
        "policyId": policyId,
        "branchId": branchId,
        "requestType": selectedRequestType,
        "subType": selectedSubType,
        "requestData": [
          isShortLeave
              ? {
                  "leaveType": "shortLeave",
                  "startDate": _combineDateAndTime(startDate!, startTime!)
                      .toIso8601String(),
                  "endDate": _combineDateAndTime(startDate!, endTime!)
                      .toIso8601String(),
                  "duration": _calculateDurationInHours(),
                }
              : {
                  "leaveType": selectedSubType,
                  "startDate":
                      startDate!.toIso8601String().split('T').first,
                  "endDate": endDate!.toIso8601String().split('T').first,
                  "duration": _totalDays.text,
                }
        ],
        "approvers": [],
        "reason": _notes.text,
        "attachments": attachments,
      };

      if (kDebugMode) print("REQUEST JSON POST: ${jsonEncode(data)}");

      if (mounted) setState(() => isLoading = true);

      final response = await http.post(
        Uri.parse("${singletonClass.baseURL}/request/create"),
        headers: singletonClass.getHeaders(),
        body: json.encode(data),
      );

      if (mounted) setState(() => isLoading = false);

      final decodedResponse = json.decode(response.body);
      if (kDebugMode) print("REQUEST RESPONSE: $decodedResponse");

      final int statusCode =
          (decodedResponse['statusCode'] ?? response.statusCode) as int;

      if (statusCode == 200) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: decodedResponse['statusMessage'] ??
              "Request completed successfully",
          autoCloseDuration: const Duration(seconds: 2),
          showConfirmBtn: false,
        );

        Future.delayed(const Duration(milliseconds: 900), () {
          if (!mounted) return;
          try {
            Navigator.of(context, rootNavigator: true).pop();
          } catch (_) {}

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    MainScreen(index: 2, selectedIndex: 0, showBanner: false)),
          );
        });
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: decodedResponse['errorMessage'] ??
              AppLocalizations.of(context)!.unexpectedError,
          autoCloseDuration: const Duration(seconds: 4),
          showConfirmBtn: false,
        );
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      if (kDebugMode) print("ERROR: $e");

      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        text: AppLocalizations.of(context)!.somethingWentWrong,
        autoCloseDuration: const Duration(seconds: 4),
        showConfirmBtn: false,
      );
    }
  }
  

  ///Helper methods for translation of text values from english to arabic
  String _translateRequestSubtype(String? status, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    switch (status) {
      case 'leave Request':
        return localizations.leaveRequests;
      case 'Sick Leave':
        return localizations.sickLeave;
      case 'Annual Leave':
        return localizations.annualLeave;
      case 'Casual Leave':
        return localizations.casualLeave;
      case 'Advance Salary Request':
        return localizations.advanceSalaryRequest;
      case 'LongTerm Loan Request':
        return localizations.longTermLoanRequest;
      case "Housing Allowance":
        return localizations.housingAllowance;
      case "Traveling Allowance":
        return localizations.travellingAllowance;
      case 'Salary Incremental Allowance':
        return localizations.salaryIncrementalAllowance;
      case "Salary Slip":
        return localizations.salarySlip;
      case "Promotional Letter":
        return localizations.promotionalLetter;
      case "Contract":
        return localizations.contract;
      case "ID Card":
        return localizations.idCard;
      case "Advance Expense":
        return localizations.advanceExpense;
      case "Business Expense":
        return localizations.businessExpense;
      case "Reimbursement":
        return localizations.reimbursement;
      case "Disbursement":
        return localizations.disbursement;
      case "Star":
        return localizations.star;
      case "Moon":
        return localizations.moon;
      case "Bad Behaviour":
        return localizations.badBehaviour;
      case "Marriage Leave":
        return localizations.marriageLeave;
      case "Exam Leave":
        return localizations.examLeave;
      case "Death Leave":
        return localizations.deathLeave;
      case "Special Document":
        return localizations.specialDocument;
      case "Maternity Leave":
        return localizations.maternityLeave;
      case "Short Leave":
        return localizations.shortLeaves;
      case "UnPaid Leave ":
        return localizations.unpaidLeave;
      default:
        return status ?? '';
    }
  }

  String _translateRequest(String? status, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    switch (status) {
      case 'Leave Request':
        return localizations.leaveRequests;
      case 'Loan Request':
        return localizations.loanRequest;
      case 'Penalty and Fine Requests':
        return localizations.penaltiesAndFine;
      case 'OverTime':
        return localizations.overTime;
      case 'Training':
        return localizations.training;
      case "Complaint Request":
        return localizations.complaints;
      case "Allowance Increment":
        return localizations.allowanceIncrement;
      case 'Document Request':
        return localizations.documentRequest;
      case "Expense Request":
        return localizations.expenseRequest;
      case "Special leave Request":
        return localizations.specialLeaveRequest;
      case "Approval Document Request":
        return localizations.approvalDocumentRequest;
      default:
        return status ?? '';
    }
  }

  String _translateBottomText(String? status, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    switch (status) {
      case 'Leave Request':
        return localizations.leaveRequestBottom;
      case 'Loan Request':
        return localizations.loanRequestBottom;
      case 'Penalty and Fine Requests':
        return localizations.penaltiesAndFineBottom;
      case 'OverTime':
        return localizations.overTime;
      case 'Training':
        return localizations.training;
      case "Complaint Request":
        return localizations.complaints;
      case "Allowance Increment":
        return localizations.allowanceIncrementBottom;
      case 'Document Request':
        return localizations.documentRequestBottom;
      case "Expense Request":
        return localizations.expenseRequestBottom;
      case "Special leave Request":
        return localizations.specialLeaveRequestBottom;
      case "Approval Document Request":
        return localizations.approvalDocumentRequestBottom;
      default:
        return status ?? '';
    }
  }
}

// ── Simple value object for leave balance display ──────────────────────────
class _BalanceInfo {
  final String entitlementLabel;
  final String usedLabel;
  final String remainingLabel;
  final bool hasBalance;

  const _BalanceInfo({
    required this.entitlementLabel,
    required this.usedLabel,
    required this.remainingLabel,
    required this.hasBalance,
  });

  factory _BalanceInfo.empty() => const _BalanceInfo(
        entitlementLabel: '—',
        usedLabel: '—',
        remainingLabel: '—',
        hasBalance: false,
      );
}
