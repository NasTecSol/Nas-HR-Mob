import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../request_controller/branch_shift_model.dart';

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

    final assignedShift = widget.employees?.shiftInfo?.shiftName ?? "";

    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 45.0, left: 20, right: 20),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 5,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Update Shift",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: NasColors.darkBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      "Assigned Shift",
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 1),
                          ),
                        ),
                        child: Text(
                          assignedShift,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      "Assign new shift",
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 1),
                    ),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedShiftId,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    style: GoogleFonts.inter(color: Colors.black, fontSize: 12),
                    hint: const Text("Select Shift"),
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
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF9DB2CE),
                            Color(0xFF8799B1),
                            Color(0xFF78889D),
                            Color(0xFF677587),
                            Color(0xFF444658),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: selectedShiftId == null
                            ? null
                            : () {
                          updateShift();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        ),
                        child: const Text(
                          "Update",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (isLoading)
              Center(
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: Lottie.asset('images/loader.json'),
                ),
              ),
          ],
        ),
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

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.patch(
        uri,
        body: body,
        headers: singletonClass.getHeaders(),
      );

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
        String errorMessage = decodedResponse['errorMessage'] ??
            'An unexpected error occurred. Please try again.';
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
      setState(() {
        isLoading = false;
      });
    }
  }
}
