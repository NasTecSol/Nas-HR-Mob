import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/screens/file_complaints_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Complaints extends StatefulWidget {
  const Complaints({super.key});

  @override
  State<Complaints> createState() => _ComplaintsState();
}

class _ComplaintsState extends State<Complaints> {
  int _selectedOptionIndex = 0;
  SingletonClass singletonClass = SingletonClass();

  late Future _approverDataFuture; // Declare Future variable

  @override
  void initState() {
    super.initState();
    _approverDataFuture =
        singletonClass.getComplaintsApproverData(); // Initialize Future in initState
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 45.0, left: 20, right: 20),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: IconButton(
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
                  padding: const EdgeInsets.only(left: 0.0, top: 0.0),
                  child: Text(
                    AppLocalizations.of(context)!.complaints,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: NasColors.darkBlue,
                    ),
                  ),
                ),
                const Spacer(),
                if (singletonClass.getJWTModel()?.grade == 'L0' ||
                    singletonClass.getJWTModel()?.grade == 'L1') ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: _selectedOptionIndex == 0
                        ? TextButton(
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
                              width: 90,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.filter_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    AppLocalizations.of(context)!.filter,
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
                          )
                        : TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const FileComplaintsScreen()));
                            },
                            child: SizedBox(
                              height: 30,
                              width: 120,
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
                                    AppLocalizations.of(context)!.fileComplain,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
                if (singletonClass.getJWTModel()?.grade == 'L2' ||
                    singletonClass.getJWTModel()?.grade == 'L3') ...[
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const FileComplaintsScreen()));
                    },
                    child: SizedBox(
                      height: 30,
                      width: 120,
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
                            AppLocalizations.of(context)!.fileComplain,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
              ],
            ),
            if (singletonClass.getJWTModel()?.grade == 'L0' ||
                singletonClass.getJWTModel()?.grade == 'L1') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildOptionsCard(
                      0, AppLocalizations.of(context)!.myComplaints),
                  buildOptionsCard(
                      1, AppLocalizations.of(context)!.teamComplaints)
                ],
              ),
            ],
            if (singletonClass.getJWTModel()?.grade == 'L2' ||
                singletonClass.getJWTModel()?.grade == 'L3') ...[
              Row(
                children: [
                  Text(
                    "Urgent",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Expanded(
                // Wrap ListView with Expanded
                  child: FutureBuilder(
                      future: singletonClass.getComplaintsData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: SizedBox(
                              height: 200,
                              width: 200,
                              child: Lottie.asset('images/loader.json'),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (snapshot.hasData) {
                          return singletonClass
                              .complaintsDataList.first.data!.isEmpty
                              ? Center(
                            child: Text(
                              AppLocalizations.of(context)!.noData,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          )
                              : ListView.builder(
                            padding: const EdgeInsets.all(5),
                            itemCount: singletonClass
                                .complaintsDataList.first.data!.length,
                            itemBuilder:
                                (BuildContext context, int index) {
                              final request = singletonClass
                                  .complaintsDataList.first.data![index];
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius:
                                  const BorderRadius.all(
                                      Radius.circular(15)),
                                  color: NasColors.containerColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey
                                          .withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 8,
                                      offset: const Offset(0,
                                          0), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "${request.employeeName}",
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight:
                                              FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            height: 20,
                                            width: 75,
                                            decoration: BoxDecoration(
                                              shape:
                                              BoxShape.rectangle,
                                              color:
                                              _getColorForVerificationStatus("${request.status}"),
                                              borderRadius:
                                              BorderRadius
                                                  .circular(10),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "${request.status}",
                                                textAlign:
                                                TextAlign.center,
                                                style:
                                                GoogleFonts.inter(
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 10,
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
                                            "${request.reason}",
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight:
                                              FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                              );
                            },
                          );
                        } else {
                          return Center(
                            child: Text(
                              AppLocalizations.of(context)!.noData,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          );
                        }
                      }))
            ],
            if (singletonClass.getJWTModel()?.grade == 'L0' ||
                singletonClass.getJWTModel()?.grade == 'L1') ...[
              if (_selectedOptionIndex == 0)
                Expanded(
                    child: FutureBuilder(
                        future: singletonClass.getComplaintsData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: SizedBox(
                                height: 200,
                                width: 200,
                                child: Lottie.asset('images/loader.json'),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else if (snapshot.hasData) {
                            return singletonClass
                                .complaintsDataList.first.data!.isEmpty
                                ? Center(
                              child: Text(
                                AppLocalizations.of(context)!.noData,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                            )
                                : ListView.builder(
                              padding: const EdgeInsets.all(5),
                              itemCount: singletonClass
                                  .complaintsDataList.first.data!.length,
                              itemBuilder:
                                  (BuildContext context, int index) {
                                final request = singletonClass
                                    .complaintsDataList.first.data![index];
                                return Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        const BorderRadius.all(
                                            Radius.circular(15)),
                                        color: NasColors.containerColor,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey
                                                .withOpacity(0.3),
                                            spreadRadius: 2,
                                            blurRadius: 8,
                                            offset: const Offset(0,
                                                0), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  "${request.employeeName}",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Container(
                                                  height: 20,
                                                  width: 75,
                                                  decoration: BoxDecoration(
                                                    shape:
                                                    BoxShape.rectangle,
                                                    color:
                                                    _getColorForVerificationStatus("${request.status}"),
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(10),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "${request.status}",
                                                      textAlign:
                                                      TextAlign.center,
                                                      style:
                                                      GoogleFonts.inter(
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        color: Colors.white,
                                                        fontSize: 10,
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
                                                  "${request.reason}",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                              },
                            );
                          } else {
                            return Center(
                              child: Text(
                                AppLocalizations.of(context)!.noData,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                            );
                          }
                        })),
              if (_selectedOptionIndex == 1)
                Expanded(
                  // Wrap ListView with Expanded
                    child: FutureBuilder(
                        future: _approverDataFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: SizedBox(
                                height: 200,
                                width: 200,
                                child: Lottie.asset('images/loader.json'),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else {
                            return singletonClass
                                .complaintsApproverDataList.first.data!.isEmpty
                                ? Center(
                              child: Text(
                                AppLocalizations.of(context)!.noData,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                            )
                                : ListView.builder(
                              padding: const EdgeInsets.all(5),
                              itemCount: singletonClass
                                  .complaintsApproverDataList.first.data!.length,
                              itemBuilder:
                                  (BuildContext context, int index) {
                                final request = singletonClass
                                    .complaintsApproverDataList.first.data![index];
                                return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        const BorderRadius.all(Radius.circular(15)),
                                        color: NasColors.containerColor,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            spreadRadius: 2,
                                            blurRadius: 8,
                                            offset: const Offset(
                                                0, 0), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  "${request.employeeName}",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Container(
                                                  height: 20,
                                                  width: 75,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.rectangle,
                                                    color: _getColorForVerificationStatus("${request.status}"),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "${request.status}",
                                                      textAlign: TextAlign.center,
                                                      style: GoogleFonts.inter(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 20),
                                            Row(
                                              children: [
                                                SizedBox(
                                                  height: 40,
                                                  width: 200,
                                                  child: Text(
                                                    "${request.reason}",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  "July 20-Tuesday",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                );
                              },
                            );
                          }
                        })),

            ],
          ],
        ),
      ),
    );
  }

  //CARDS
  Widget buildOptionsCard(int index, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptionIndex = index;
        });
      },
      child: SizedBox(
        height: 70,
        width: 170,
        child: Card(
          color:
              _selectedOptionIndex == index ? NasColors.darkBlue : Colors.white,
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(
              color:
                  _selectedOptionIndex == index ? Colors.white : Colors.white,
              width: 0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _selectedOptionIndex == index
                      ? Colors.white
                      : NasColors.darkBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        return Colors.grey; // or any other default color
    }
  }
}
