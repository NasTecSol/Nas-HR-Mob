import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/widgets/colors.dart';

class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  final List<LoanModel> loans = [
    LoanModel(
        "March 2024",
        "paid",
        "1000 SAR",
        "3000 SAR",),
    LoanModel(
        "April 2024",
        "paid",
        "1000 SAR",
        "2000 SAR",),
    LoanModel(
        "May 2024",
        "remaining",
        "1000 SAR",
        "2000 SAR",),
    LoanModel(
      "June 2024",
      "remaining",
      "1000 SAR",
      "2000 SAR",)
  ];
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0,left: 20.0,right: 20.0),
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
                          ]),
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
                      //Add your onPressed functionality here
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
                  "4000.00 SAR",
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
                  "2000.00 SAR",
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
                  itemCount: loans.length,
                  itemBuilder: (BuildContext context, int index) {
                    final loan = loans[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 50,
                            width: 100,
                            child: Text(
                              loan.month ?? '',
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
                                      color: loan.status == 'paid'
                                          ? NasColors.onTime
                                          : loan.status == 'remaining'
                                          ? NasColors.pending
                                          : Colors.orange,
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
                              if (index < loans.length - 1)
                                Container(
                                  width: 2, // Thickness of the divider
                                  height: 50, // Height of the divider, adjusted for better fit
                                  color: Colors.grey, // Color of the divider
                                  margin: const EdgeInsets.only(top: 0, bottom: 0), // Adjust to position the divider
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
                                    children: [
                                      if (loan.status == "paid")
                                        Icon(Icons.done, color: NasColors.onTime, size: 30),
                                      if (loan.status == "remaining")
                                        Icon(Icons.hourglass_bottom_outlined,
                                            color: NasColors.pending, size: 30),
                                      const SizedBox(width: 5),
                                      if (loan.status == "paid")
                                        Text(
                                          "${loan.status} ${loan.paidAmount}",
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: NasColors.darkBlue,
                                          ),
                                        ),
                                      if (loan.status == "remaining")
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
                                  const SizedBox(height: 5),
                                  Text(
                                    "Remaining ${loan.remainingAmount}",
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
class LoanModel {
  String? month;
  String? status;
  String? paidAmount;
  String? remainingAmount;

  LoanModel(this.month, this.status, this.paidAmount, this.remainingAmount);
}