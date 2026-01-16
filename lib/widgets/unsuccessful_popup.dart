import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class UnsuccessfulPopup extends StatelessWidget {
  const UnsuccessfulPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: _UnsuccessfulPopupContent(),
    );
  }
}

class _UnsuccessfulPopupContent extends StatelessWidget {
  const _UnsuccessfulPopupContent();

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });

    return SizedBox(
      height: 150,
      width: 150,
      child: Lottie.asset(
        'images/unsuccessfull.json',
        fit: BoxFit.contain,
      ),
    );
  }
}
