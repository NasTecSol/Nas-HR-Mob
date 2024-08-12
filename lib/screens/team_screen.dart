import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/widgets/colors.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final List<TeamModel> teams = [
    TeamModel(
        "https://img.freepik.com/premium-photo/happy-fashionable-handsome-man_739685-5867.jpg?w=740",
        "Suleman Azeem Khan",
        "suleman.nastecsol@gmail,com"),
    TeamModel(
        "https://img.freepik.com/premium-photo/smiling-businessman-formal-wear-using-tablet-while-standing-rooftop_1289061-391.jpg?w=740",
        "Muhammad Ali Rana",
        "alirana.nastecol@gmail.com"),
    TeamModel(
        "https://img.freepik.com/premium-vector/man-suit-tie-is-smiling-looking-camera_697880-29692.jpg?w=740",
        "Arqum Naeem",
        "arqumnaeem.nastecol@gmail.com"),
    TeamModel(
        "https://img.freepik.com/free-photo/confident-handsome-guy-posing-against-white-wall_176420-32936.jpg?t=st=1723452897~exp=1723456497~hmac=d1063ee18ade6b4f24d492b93758d241342ffeca0abc0759b44bfe7a0986bb4c&w=996",
        "Shoaib Sardar",
        "shoaibsardar.nastecol@gmail.com"),
    TeamModel(
        "https://img.freepik.com/free-psd/flat-man-character_23-2151534197.jpg?w=740&t=st=1723453930~exp=1723454530~hmac=f047b2fdb91350768e41906694186ffddadcde4b49b6d55de3083dfb18cbe3e3",
        "Imad Shareef",
        "imadshareef.nastecol@gmail.com"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
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
                      padding: const EdgeInsets.only(left: 0.0, top: 0.0),
                      child: Text(
                        "Team",
                        style: GoogleFonts.inter(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: NasColors.darkBlue,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(top: 0.0),
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
                          width: 100,
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
                                "Filter",
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
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width - 50,
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
                          cursorColor: Colors.black,
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
                ListView.builder(
                    padding: const EdgeInsets.all(5),
                    shrinkWrap: true,
                    itemCount: teams.length,
                    itemBuilder: (BuildContext context, int index) {
                      final team = teams[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 15),
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
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Container(
                                height: 50,
                                width: 60,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: NetworkImage('${team.imageURL}'),
                                        fit: BoxFit.fill)),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${team.employeeName}",
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: NasColors.darkBlue,
                                    ),
                                  ),
                                  Text(
                                    "${team.email}",
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              SizedBox(
                                  width: 60,
                                  child: IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.more_vert,
                                        size: 35,
                                      )))
                            ],
                          ),
                        ),
                      );
                    })
              ],
            ),
          )
        ],
      ),
    );
  }
}
class TeamModel {
  String? imageURL;
  String? employeeName;
  String? email;

  TeamModel(this.imageURL, this.employeeName, this.email);
}
