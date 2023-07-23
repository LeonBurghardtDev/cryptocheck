import 'package:flutter/material.dart';

/// shows an error dialog when the user is rate-limited
void showRateLimitErrorDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error'),
        content: const Text(
            'Failed to fetch data. You may be rate-limited. Wait a few seconds and try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
