import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FaceIdPopup extends StatelessWidget {
  const FaceIdPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: _FaceIdPopupContent(),
    );
  }
}

class _FaceIdPopupContent extends StatelessWidget {
  const _FaceIdPopupContent();

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
    return SizedBox(
      height: 300,
      width: 300,
      child: Lottie.asset(
        'images/faceID.json',
        fit: BoxFit.contain,
      ),
    );
  }
}
