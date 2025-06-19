import 'package:flutter/material.dart';

class CustomizedButton extends StatelessWidget {
  final String buttonText;
  final Color buttonColor;
  final Color textColor;
  final VoidCallback onPressed;
  final Gradient? gradient;
  final double elevation;
  final double borderRadius;
  final Color borderColor;
  final double height;
  final double? width;

  const CustomizedButton({
    Key? key,
    required this.buttonText,
    required this.buttonColor,
    required this.textColor,
    required this.onPressed,
    this.gradient,
    this.elevation = 4,
    this.borderRadius = 16,
    this.borderColor = Colors.transparent,
    this.height = 60,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Material(
        elevation: elevation,
        borderRadius: BorderRadius.circular(borderRadius),
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Ink(
            height: height,
            width: width ?? MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: gradient,
              color: gradient == null ? buttonColor : null,
              border: Border.all(
                color: borderColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                if (elevation > 0)
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: elevation * 2,
                    spreadRadius: elevation * 0.5,
                    offset: Offset(0, elevation),
                  ),
              ],
            ),
            child: Center(
              child: Text(
                buttonText,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}