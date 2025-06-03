import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';

class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  SingletonClass singletonClass = SingletonClass();
  List<Map<String, String>> loanInstallments = [];
  String totalLoan = "0";
  String paidAmount = "0";
  String remainingAmount = "0";

  int _extractLoanDuration(String loanDuration) {
    final RegExp regex = RegExp(r'\d+');
    final match = regex.firstMatch(loanDuration);
    return match != null ? int.parse(match.group(0)!) : 0;
  }

  List<Map<String, String>> _generateLoanInstallments(
      String issueDate,
      int totalInstallments,
      int paidInstallments,
      String installmentAmount,
      ) {
    List<Map<String, String>> installments = [];

    print(issueDate);
    if (issueDate.trim().isEmpty) {
      print("Invalid issueDate: empty or null");
      return installments; // Return empty list if invalid date
    }

    DateTime startDate;
    try {
      // Try parsing with standard ISO format
      startDate = DateTime.parse(issueDate);
    } catch (_) {
      try {
        // Fallback to dd-MM-yyyy if not ISO
        startDate = DateFormat('dd-MM-yyyy').parse(issueDate);
      } catch (e) {
        print("Date parsing failed: $e");
        return installments; // Or show error if needed
      }
    }

    for (int i = 0; i < totalInstallments; i++) {
      int correctMonth = (startDate.month + i - 1) % 12 + 1;
      int yearAdjustment = (startDate.month + i - 1) ~/ 12;
      DateTime installmentDate = DateTime(startDate.year + yearAdjustment, correctMonth, startDate.day);

      String monthYear = DateFormat.yMMMM().format(installmentDate);
      String status = i < paidInstallments ? "paid" : "remaining";
      String paidAmt = i < paidInstallments ? installmentAmount : "0";

      installments.add({
        "month": monthYear,
        "status": status,
        "paidAmount": paidAmt,
        "remainingAmount": installmentAmount,
      });
    }

    return installments;
  }


  @override
  Widget build(BuildContext context) {
    final employeeDataList = singletonClass.employeeDataList;

    if (employeeDataList.isEmpty ||
        employeeDataList.first.data == null ||
        employeeDataList.first.data!.loanInfo == null ||
        employeeDataList.first.data!.loanInfo!.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No loan information available')),
      );
    }

    final loanInfo = employeeDataList.first.data!.loanInfo!.first;

    // Null-safe extraction
    totalLoan = loanInfo.totalLoanAmount?.toString() ?? "0";
    paidAmount = loanInfo.paidAmount?.toString() ?? "0";

    double totalLoanValue = double.tryParse(totalLoan) ?? 0;
    double paidAmountValue = double.tryParse(paidAmount) ?? 0;
    remainingAmount = (totalLoanValue - paidAmountValue).toStringAsFixed(2);

    final rawLoanDuration = loanInfo.loanDuration?.toString() ?? "0";
    int totalInstallments = _extractLoanDuration(rawLoanDuration);

    final issueDate = loanInfo.loanIssueDate;
    final paidInstallments = int.tryParse(loanInfo.paidInstallments?.toString() ?? "0") ?? 0;
    final installmentAmount = loanInfo.installmentAmount?.toString() ?? "0";

    if (issueDate != null) {
      loanInstallments = _generateLoanInstallments(issueDate, totalInstallments, paidInstallments, installmentAmount);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.totalAmount,
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: NasColors.darkBlue)),
                Text(totalLoan,
                    style: GoogleFonts.inter(fontSize: 25, fontWeight: FontWeight.bold, color: NasColors.darkBlue)),
                const SizedBox(height: 10),
                Text(AppLocalizations.of(context)!.remainingAmount,
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: NasColors.darkBlue)),
                Text(remainingAmount,
                    style: GoogleFonts.inter(fontSize: 25, fontWeight: FontWeight.bold, color: NasColors.darkBlue)),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(AppLocalizations.of(context)!.month,
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: NasColors.darkBlue)),
                  ),
                  Expanded(
                    child: Text(AppLocalizations.of(context)!.status,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: NasColors.darkBlue)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: loanInstallments.length,
                  itemBuilder: (BuildContext context, int index) {
                    final loan = loanInstallments[index];
                    return Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 50,
                            width: 100,
                            child: Text(loan['month'] ?? '',
                                style: GoogleFonts.inter(
                                    fontSize: 15, color: NasColors.darkBlue, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 5),
                          Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    height: 35,
                                    width: 35,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: loan['status'] == 'paid'
                                          ? NasColors.onTime
                                          : NasColors.pending,
                                    ),
                                  ),
                                  Container(
                                    height: 15,
                                    width: 15,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              if (index < loanInstallments.length - 1)
                                Container(
                                  width: 2,
                                  height: 50,
                                  color: Colors.grey,
                                ),
                            ],
                          ),
                          const SizedBox(width: 7.5),
                          Expanded(
                            child: SizedBox(
                              height: 75,
                              child: Row(
                                children: [
                                  Icon(
                                    loan['status'] == "paid"
                                        ? Icons.done
                                        : Icons.hourglass_bottom_outlined,
                                    color: loan['status'] == "paid"
                                        ? NasColors.onTime
                                        : NasColors.pending,
                                    size: 30,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    loan['status'] == "paid"
                                        ? "Paid ${loan['paidAmount']}"
                                        : "To be paid",
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: NasColors.darkBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
