import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/colors.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final List<RequestModel> requests = [
    RequestModel(
        "M Ali Rana",
        "Jr UI/UX Copy paste",
        "pending",
        "July 12 - July 14",
        "Going to Mt. Fuji to visit a friend in Japan  will be back on July 4 at 12:00 PM in the Afternoon, will bring some treats also!",
        "15 Days",
        "24 Days"),
    RequestModel(
        "Shoaib Sardar",
        "Jr CSS Officer",
        "Approved",
        "July 14 - July 16",
        "Going to Mt. Fuji to visit a friend in Japan  will be back on July 4 at 12:00 PM in the Afternoon, will bring some treats also!",
        "15 Days",
        "24 Days"),
    RequestModel(
        "Arqum Naeem",
        "Jr Clerk",
        "Rejected",
        "July 16 - July 22",
        "Going to Mt. Fuji to visit a friend in Japan  will be back on July 4 at 12:00 PM in the Afternoon, will bring some treats also!",
        "15 Days",
        "24 Days"),
  ];
  int? _expandedIndex; // Keeps track of the index of the expanded container

  void _toggleExpand(int index) {
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null; // Collapse if the same item is clicked again
      } else {
        _expandedIndex = index; // Expand the clicked item
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0,left: 20.0,right: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5.0, top: 15.0),
                  child: Text(
                    "Requests",
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width - 100,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.search,
                        color: NasColors.darkBlue,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.filter_list_alt,
                    size: 35,
                    color: NasColors.darkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              // Wrap ListView with Expanded
              child: ListView.builder(
                padding: const EdgeInsets.all(5),
                itemCount: requests.length,
                itemBuilder: (BuildContext context, int index) {
                  final request = requests[index];
                  return GestureDetector(
                    onTap: () => _toggleExpand(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: 80,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          image: const DecorationImage(
                                            image: AssetImage('images/DP.jpg'),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      SizedBox(
                                        width: 200,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                "${request.employeeName}",
                                                style: GoogleFonts.inter(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                "${request.designation}",
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Container(
                                        height: 30,
                                        width: 75,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: _getColorForVerificationStatus(request.status!),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${request.status}",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "${request.duration}",
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  if (_expandedIndex == index) ...[
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "${request.requestInfo}",
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "Annual Leave",
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "Balance to Date",
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "${request.balanceToDate}",
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "Balance to end of Year",
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        "${request.balanceToYear}",
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(30.0),
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          width: 220,
                                          height: 50,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(15)),
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
                                              "Cancel Request",
                                              style: GoogleFonts.inter(
                                                fontSize: 19,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Color _getColorForVerificationStatus(String verificationStatus) {
    switch (verificationStatus) {
      case 'Approved':
        return NasColors.completed;
      case 'pending':
        return Colors.yellow;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey; // or any other default color
    }
  }
}

class RequestModel {
  String? employeeName;
  String? designation;
  String? status;
  String? duration;
  String? requestInfo;
  String? balanceToDate;
  String? balanceToYear;

  RequestModel(this.employeeName, this.designation, this.status, this.duration,
      this.requestInfo, this.balanceToDate, this.balanceToYear);
}
