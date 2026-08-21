import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:nashr/request_controller/company_notification_model.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/widgets/loader.dart';

class EditCompanyNotificationScreen extends StatefulWidget {
  final Data? companyNotifications;
  const EditCompanyNotificationScreen({super.key, this.companyNotifications});

  @override
  State<EditCompanyNotificationScreen> createState() =>
      _EditCompanyNotificationScreenState();
}

class _EditCompanyNotificationScreenState
    extends State<EditCompanyNotificationScreen> {
  SingletonClass singletonClass = SingletonClass();
  bool isLoading = false;
  late TextEditingController nameController;
  late TextEditingController typeController;
  late TextEditingController expiryDateController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
        text: widget.companyNotifications?.attachmentName ?? '');
    typeController = TextEditingController(
        text: widget.companyNotifications?.objectType ?? '');
    expiryDateController = TextEditingController(
        text: widget.companyNotifications?.expiryDate ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Curved Header (NO icon in header text)
              _buildHeader(context, local),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Document Name
                        _buildFieldLabel(local.name, icon: Icons.description_rounded),
                        TextFormField(
                          controller: nameController,
                          cursorColor: NasColors.darkBlue,
                          decoration: _buildInputDecoration(
                            hintText: local.name,
                          ),
                        ),
                        const SizedBox(height: 18),

                        /// Document Type
                        _buildFieldLabel(local.type, icon: Icons.category_rounded),
                        TextFormField(
                          controller: typeController,
                          readOnly: true,
                          decoration: _buildInputDecoration(
                            hintText: local.type,
                          ),
                        ),
                        const SizedBox(height: 18),

                        /// Expiry Date
                        _buildFieldLabel(local.expiryDate,
                            icon: Icons.calendar_month_rounded),
                        TextFormField(
                          controller: expiryDateController,
                          readOnly: true,
                          decoration: _buildInputDecoration(
                            hintText: local.expiryDate,
                            suffixIcon: Icon(Icons.calendar_month_rounded,
                                color: NasColors.darkBlue),
                          ),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  DateTime.tryParse(expiryDateController.text) ??
                                      DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              builder: (BuildContext context, Widget? child) {
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
                                        foregroundColor: NasColors.darkBlue,
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              expiryDateController.text =
                                  DateFormat('yyyy-MM-dd').format(picked);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// Bottom Action Buttons (Cancel / Update)
              _buildBottomNavigation(context, local),
            ],
          ),
          if (isLoading) const Loader(),
        ],
      ),
    );
  }

  // ── Header (Gradient with Back button, NO decorative logo icon) ──────────
  Widget _buildHeader(BuildContext context, AppLocalizations local) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 20,
      ),
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
            color: NasColors.darkBlue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.18),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              "${local.edit} ${local.notifications}",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Field Label Helper ────────────────────────────────────────────────
  Widget _buildFieldLabel(String labelText, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: NasColors.darkBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: NasColors.darkBlue),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            labelText,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ── Input Decoration Helper ───────────────────────────────────────────
  InputDecoration _buildInputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: NasColors.darkBlue, width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  // ── Bottom Navigation Bar ──────────────────────────────────────────────
  Widget _buildBottomNavigation(BuildContext context, AppLocalizations local) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                local.cancel,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                DateTime expiryDate = DateTime.parse(expiryDateController.text);
                DateTime currentDate = DateTime.now();
                final response = await http.patch(
                  Uri.parse(
                      '${singletonClass.baseURL}/doc-notifications/${widget.companyNotifications!.id}'),
                  headers: singletonClass.getHeaders(),
                  body: jsonEncode({
                    "companyId": widget.companyNotifications!.companyId,
                    "branchId": widget.companyNotifications!.branchId,
                    "attachmentName": nameController.text.isNotEmpty
                        ? nameController.text.trim()
                        : widget.companyNotifications!.attachmentName,
                    "attachmentURL": widget.companyNotifications!.attachmentUrl,
                    "expiryDate": expiryDateController.text.isNotEmpty
                        ? expiryDateController.text.trim()
                        : widget.companyNotifications!.expiryDate,
                    "objectType": widget.companyNotifications!.objectType,
                    "objectId": widget.companyNotifications!.objectId,
                    "status": expiryDate.isAfter(currentDate)
                        ? 'active'
                        : widget.companyNotifications!.status,
                    "notificationBegins":
                        widget.companyNotifications!.notificationBegins,
                    "notificationPeriod":
                        widget.companyNotifications!.notifcationPeriod
                  }),
                );

                if (response.statusCode == 200 || response.statusCode == 204) {
                  setState(() {
                    isLoading = false;
                  });
                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: NasColors.darkBlue,
                foregroundColor: Colors.white,
                elevation: 2,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              label: Text(
                local.update,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
