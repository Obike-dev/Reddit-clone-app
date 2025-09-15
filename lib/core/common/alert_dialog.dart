import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class ReusableAlertDialog extends ConsumerWidget {
  final String confirmationText;
  final void Function()? onPressedAction;
  const ReusableAlertDialog({
    super.key,
    required this.confirmationText,
    required this.onPressedAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text(
        'Log Out',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      content: Text(
        confirmationText,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Routemaster.of(context).pop(),
          child: const Text(
            'No',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            onPressedAction?.call();
            Routemaster.of(context).pop();
          },
          child: const Text(
            'Yes',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }
}
