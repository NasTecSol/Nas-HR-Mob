import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/widgets/colors.dart';

class NasHeading extends StatelessWidget {
  final String text;
  const NasHeading({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style:  GoogleFonts.inter(
        fontSize: 25,
        color: NasColors.darkBlue,
        fontWeight: FontWeight.bold
      ),
    );
  }
}

class NasSubHeading extends StatelessWidget {
  final String text;
  const NasSubHeading({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style:  GoogleFonts.inter(
        fontSize: 20,
        color: NasColors.darkBlue,
        fontWeight: FontWeight.bold
      ),
    );
  }
}

class NasText extends StatelessWidget {
  final String text;
  const NasText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style:  GoogleFonts.inter(
        fontSize: 18,
        color: Colors.black,
        fontWeight: FontWeight.w500
      ),
    );
  }
}


class NasText15 extends StatelessWidget {
  final String text;
  const NasText15({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style:  GoogleFonts.inter(
        fontSize: 15,
        color: Colors.black,
        fontWeight: FontWeight.w600
      ),
    );
  }
}

class NasGreyText extends StatelessWidget {
  final String text;
  const NasGreyText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style:  GoogleFonts.inter(
          fontSize: 18,
          color: Colors.grey,
          fontWeight: FontWeight.bold
      ),
    );
  }
}
class NasLightGreyText extends StatelessWidget {
  final String text;
  const NasLightGreyText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style:  GoogleFonts.inter(
          fontSize: 18,
          color: Colors.grey,
          fontWeight: FontWeight.w500
      ),
    );
  }
}