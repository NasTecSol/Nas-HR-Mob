import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SuccessfulPopup extends StatelessWidget {
  const SuccessfulPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: _SuccessfulPopupContent(),
    );
  }
}

class _SuccessfulPopupContent extends StatelessWidget {
  const _SuccessfulPopupContent();

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });

    return SizedBox(
      height: 200,
      width: 200,
      child: Lottie.asset(
        'images/verified.json',
        fit: BoxFit.contain,
      ),
    );
  }
}

