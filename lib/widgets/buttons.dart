import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nashr/widgets/colors.dart';


class NasButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const NasButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          height: 45,
          decoration: BoxDecoration(
            borderRadius:  const BorderRadius.all(Radius.circular(10)),
            color: NasColors.darkBlue,
          ),
          child:Align(
              alignment: Alignment.center,
              child: Text(text,
                style:  GoogleFonts.inter(
                  fontSize: 19,
                  color: Colors.white,
                ),
              )),
        ),
      ),
    );
  }
}