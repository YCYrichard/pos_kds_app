import 'package:flutter/material.dart';

class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.onDigitTap,
    required this.onBackspaceTap,
    required this.onClearTap,
  });

  final ValueChanged<String> onDigitTap;
  final VoidCallback onBackspaceTap;
  final VoidCallback onClearTap;

  @override
  Widget build(BuildContext context) {
    final buttons = ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'C', '0', '⌫'];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: buttons.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) {
        final label = buttons[index];
        return FilledButton.tonal(
          onPressed: () {
            if (label == 'C') {
              onClearTap();
              return;
            }
            if (label == '⌫') {
              onBackspaceTap();
              return;
            }
            onDigitTap(label);
          },
          child: Text(label, style: Theme.of(context).textTheme.headlineSmall),
        );
      },
    );
  }
}
