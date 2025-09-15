import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final String error;
  const ErrorMessage({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(error),
      ),
    );
  }
}
