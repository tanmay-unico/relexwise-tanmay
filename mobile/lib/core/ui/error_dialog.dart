import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String message) async {
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Oops'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}


