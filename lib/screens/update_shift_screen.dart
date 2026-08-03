import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:nashr/l10n/app_localizations.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../request_controller/branch_shift_model.dart';
import '../widgets/loader.dart';

class UpdateShiftScreen extends StatefulWidget {
  final Employees? employees;
  const UpdateShiftScreen({super.key, this.employees});

  @override
  State<UpdateShiftScreen> createState() => _UpdateShiftScreenState();
}

class _UpdateShiftScreenState extends State<UpdateShiftScreen> {
  SingletonClass singletonClass = SingletonClass();
  String? selectedShiftId;
  bool isLoading = false;

  // ── Helper: Info Row ──────────────────────────────────────────────────────
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NasColors.darkBlue.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: NasColors.darkBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: NasColors.darkBlue),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shiftDataList = singletonClass.branchesModelDataList;

    final shifts = shiftDataList.isNotEmpty
        ? shiftDataList.first.data?.branch?.departmentDetails
                ?.expand((dept) => dept.shifts ?? [])
                .where((shift) => shift.shiftId != null && shift.shiftName != null)
                .toList() ??
            []
        : [];

    final assignedShift = widget.employees?.shiftInfo?.shiftName ?? "—";
    final employeeName = widget.employees?.userName ?? "—";
    final empId = widget.employees?.employeeInfo?.first.empId ?? "—";

    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Stack(
        children: [
          Column(
            children: [
              // ── Header ────────────────────────────────────────────────────
              Container(
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
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Update Shift",
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ── Employee Card ──────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: NasColors.darkBlue.withOpacity(0.06)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: NasColors.darkBlue.withOpacity(0.08),
                              radius: 28,
                              child: Image.asset('images/DP.png', fit: BoxFit.cover, width: 56, height: 56),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    employeeName,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: NasColors.darkBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.badge_outlined, size: 14, color: Colors.grey.shade500),
                                      const SizedBox(width: 4),
                                      Text(
                                        empId,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
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

                      const SizedBox(height: 14),

                      // ── Current Shift ──────────────────────────────────────
                      _buildInfoCard(
                        icon: Icons.work_history_rounded,
                        label: "Assigned Shift",
                        child: Row(
                          children: [
                            Container(
                              height: 26,
                              width: 26,
                              decoration: BoxDecoration(
                                color: NasColors.darkBlue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Icon(Icons.access_time_filled_rounded, size: 14, color: NasColors.darkBlue),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              assignedShift,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: NasColors.darkBlue,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── New Shift Dropdown ─────────────────────────────────
                      _buildInfoCard(
                        icon: Icons.swap_horiz_rounded,
                        label: "Assign New Shift",
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: NasColors.backGround,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: NasColors.darkBlue.withOpacity(0.15)),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: selectedShiftId,
                            isExpanded: true,
                            icon: Icon(Icons.keyboard_arrow_down_rounded, color: NasColors.darkBlue),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            dropdownColor: Colors.white,
                            borderRadius: const BorderRadius.all(Radius.circular(16)),
                            style: GoogleFonts.inter(
                              color: NasColors.darkBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            hint: Text(
                              "Select Shift",
                              style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
                            ),
                            items: shifts
                                .map((shift) => DropdownMenuItem<String>(
                                      value: shift.shiftId!,
                                      child: Text(shift.shiftName!),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedShiftId = value;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Update Button ──────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: selectedShiftId != null
                                  ? [NasColors.darkBlue, NasColors.lightBlue]
                                  : [Colors.grey.shade300, Colors.grey.shade400],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: selectedShiftId != null
                                ? [
                                    BoxShadow(
                                      color: NasColors.darkBlue.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: selectedShiftId == null ? null : () => updateShift(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              disabledBackgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            icon: const Icon(Icons.save_rounded, color: Colors.white, size: 20),
                            label: Text(
                              "Update Shift",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isLoading) const Loader(),
        ],
      ),
    );
  }

  // API CALL
  Future<void> updateShift() async {
    final shiftId = selectedShiftId;
    final employeeId = widget.employees?.id;

    if (shiftId == null || employeeId == null) return;

    Map<String, dynamic> data = {
      "employeeIds": [employeeId]
    };

    String body = json.encode(data);
    final uri = Uri.parse('${singletonClass.baseURL}/employee/updateMultipleEmployeesShifts/$shiftId');

    setState(() => isLoading = true);

    try {
      final response = await http.patch(uri, body: body, headers: singletonClass.getHeaders());

      final decodedResponse = json.decode(response.body);
      int responseCode = decodedResponse['statusCode'] ?? response.statusCode;

      if (responseCode == 200) {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Success',
          text: decodedResponse['statusMessage'] ?? 'Request completed successfully.',
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
        Navigator.pop(context);
      } else {
        String errorMessage = decodedResponse['errorMessage'] ?? 'An unexpected error occurred. Please try again.';
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: errorMessage,
          autoCloseDuration: const Duration(seconds: 5),
          showCancelBtn: false,
          showConfirmBtn: false,
        );
      }
    } catch (e) {
      await QuickAlert.show(
        autoCloseDuration: const Duration(seconds: 5),
        showCancelBtn: false,
        showConfirmBtn: false,
        context: context,
        title: AppLocalizations.of(context)!.internalServerError,
        text: AppLocalizations.of(context)!.tryAgain,
        type: QuickAlertType.error,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}
