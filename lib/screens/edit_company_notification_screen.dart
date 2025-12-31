import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:nashr/request_controller/company_notification_model.dart';
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
    nameController =
        TextEditingController(text: widget.companyNotifications?.attachmentName ?? '');
    typeController =
        TextEditingController(text: widget.companyNotifications?.objectType ?? '');
    expiryDateController =
        TextEditingController(text: widget.companyNotifications?.expiryDate ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
        child: Stack(
          children: [ Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
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
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_outlined),
                    ),
                  ),
                  Text(
                    "${AppLocalizations.of(context)!.edit} ${AppLocalizations.of(context)!.notifications}",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              /// Name
              Text(AppLocalizations.of(context)!.name,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: nameController,
                cursorColor: Colors.grey,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              /// Type
              Text(AppLocalizations.of(context)!.type, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: typeController,
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(AppLocalizations.of(context)!.expiryDate,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600
                  )),
              const SizedBox(height: 6),
              TextFormField(
                controller: expiryDateController,
                readOnly: true,
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.calendar_month),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
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
              const Spacer(),
            ],
          ),
            if(isLoading)
              Loader()
          ]
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
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
              onTap: () async {
                setState(() {
                  isLoading = true;
                });
                DateTime expiryDate = DateTime.parse(expiryDateController.text);
                DateTime currentDate = DateTime.now();
                final response = await http.patch(
                  Uri.parse('${singletonClass.baseURL}/doc-notifications/${widget.companyNotifications!.id}'),
                  headers: singletonClass.getHeaders(),
                  body: jsonEncode({
                    "companyId": widget.companyNotifications!.companyId,
                    "branchId": widget.companyNotifications!.branchId,
                    "attachmentName":nameController.text.isNotEmpty ? nameController.text.trim() : widget.companyNotifications!.attachmentName,
                    "attachmentURL": widget.companyNotifications!.attachmentUrl,
                    "expiryDate": expiryDateController.text.isNotEmpty ? expiryDateController.text.trim() : widget.companyNotifications!.expiryDate,
                    "objectType": widget.companyNotifications!.objectType,
                    "objectId": widget.companyNotifications!.objectId,
                    "status": expiryDate.isAfter(currentDate) ? 'active' : widget.companyNotifications!.status,
                    "notificationBegins": widget.companyNotifications!.notificationBegins,
                    "notificationPeriod": widget.companyNotifications!.notifcationPeriod
                  }),
                );

                if (response.statusCode == 200 || response.statusCode == 204) {
                  setState(() {
                    isLoading = false;
                  });
                  Navigator.pop(context, true);
                }
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
                    AppLocalizations.of(context)!.update,
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
    );
  }
}
