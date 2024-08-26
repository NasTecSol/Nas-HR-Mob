import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';

class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  SingletonClass singletonClass = SingletonClass();
  String totalLoan = (SingletonClass().employeeDataList.first.data!.loanInfo!.first.totalLoanAmount).toString();
  String paidAmount = (SingletonClass().employeeDataList.first.data!.loanInfo!.first.paidAmount).toString();
  String remainingAmount = "";
  late List<Map<String, String>> loanInstallments;

  int _extractLoanDuration(String loanDuration) {
    // Extract the numeric part from the loanDuration string
    final RegExp regex = RegExp(r'\d+');
    final match = regex.firstMatch(loanDuration);

    if (match != null) {
      return int.parse(match.group(0)!);
    } else {
      throw Exception('Invalid loanDuration format');
    }
  }

  List<Map<String, String>> _generateLoanInstallments(
      String issueDate, int totalInstallments, int paidInstallments, String installmentAmount) {
    List<Map<String, String>> loanInstallments = [];
    DateTime startDate = DateTime.parse(issueDate);

    for (int i = 0; i < totalInstallments; i++) {
      DateTime installmentDate = DateTime(startDate.year, startDate.month + i, startDate.day);

      // Adjust the month and year correctly to prevent overflow
      int correctMonth = (startDate.month + i - 1) % 12 + 1;
      int yearAdjustment = (startDate.month + i - 1) ~/ 12;
      installmentDate = DateTime(startDate.year + yearAdjustment, correctMonth, startDate.day);

      String monthYear = DateFormat.yMMMM().format(installmentDate);
      String status = i < paidInstallments ? "paid" : "remaining";
      String paidAmount = i < paidInstallments ? installmentAmount : "0";

      loanInstallments.add({
        "month": monthYear,
        "status": status,
        "paidAmount": paidAmount,
        "remainingAmount": installmentAmount,
      });
    }

    return loanInstallments;
  }

  @override
  Widget build(BuildContext context) {
    final loanInfo = singletonClass.employeeDataList.first.data?.loanInfo;
    if (loanInfo == null || loanInfo.isEmpty) {
      return const Center(child: Text('No loan information available'));
    }

    // Calculate the remaining amount
    double totalLoanValue = double.parse(totalLoan);
    double paidAmountValue = double.parse(paidAmount);
    double remainingAmountValue = totalLoanValue - paidAmountValue;
    remainingAmount = remainingAmountValue.toString();

    // Extract the loan duration
    int totalInstallments = _extractLoanDuration(loanInfo.first.loanDuration!);

    // Generate loan installments
    loanInstallments = _generateLoanInstallments(
      loanInfo.first.loanIssueDate!,
      totalInstallments,
      int.parse(loanInfo.first.paidInstallments!),
      loanInfo.first.installmentAmount!,
    );

    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 0.0, top: 15.0),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Container(
                      height: 50,
                      width: 50,
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
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0, top: 15.0),
                  child: Text(
                    "Loans",
                    style: GoogleFonts.inter(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: NasColors.darkBlue,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: NasColors.darkBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      // Add your onPressed functionality here
                    },
                    child: SizedBox(
                      height: 30,
                      width: 130,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Requests",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Total Amount",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: NasColors.darkBlue,
                  ),
                ),
                Text(
                  totalLoan,
                  style: GoogleFonts.inter(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: NasColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Remaining Amount",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: NasColors.darkBlue,
                  ),
                ),
                Text(
                  remainingAmount,
                  style: GoogleFonts.inter(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: NasColors.darkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Month",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: NasColors.darkBlue,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Status",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: NasColors.darkBlue,
                      ),
                    ),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 50,
                            width: 100,
                            child: Text(
                              loan['month'] ?? '',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: NasColors.darkBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
                              // Only show the divider if not the last item
                              if (index < loanInstallments.length - 1)
                                Container(
                                  width: 2,
                                  height: 50,
                                  color: Colors.grey,
                                  margin: const EdgeInsets.only(top: 0, bottom: 0),
                                ),
                            ],
                          ),
                          const SizedBox(width: 7.5),
                          Expanded(
                            child: SizedBox(
                              height: 75,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      if (loan['status'] == "paid")
                                        Icon(Icons.done, color: NasColors.onTime, size: 30),
                                      if (loan['status'] == "remaining")
                                        Icon(Icons.hourglass_bottom_outlined,
                                            color: NasColors.pending, size: 30),
                                      const SizedBox(width: 5),
                                      if (loan['status'] == "paid")
                                        Text(
                                          "Paid ${loan['paidAmount']}",
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: NasColors.darkBlue,
                                          ),
                                        ),
                                      if (loan['status'] == "remaining")
                                        Text(
                                          "To be paid",
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: NasColors.darkBlue,
                                          ),
                                        ),
                                    ],
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
