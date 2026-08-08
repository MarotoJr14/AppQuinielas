import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class InicialAvatar extends StatelessWidget {
  final String inicial;
  final double radio;

  const InicialAvatar({super.key, required this.inicial, this.radio = 18});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radio,
      backgroundColor: AppColors.acento,
      child: Text(
        inicial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radio * 0.85,
        ),
      ),
    );
  }
}
