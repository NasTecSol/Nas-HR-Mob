import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: _LoaderContent(),
    );
  }
}

class _LoaderContent extends StatelessWidget {
  const _LoaderContent();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: 250,
      child: Lottie.asset(
        'images/loader.json',
        fit: BoxFit.contain,
      ),
    );
  }
}
