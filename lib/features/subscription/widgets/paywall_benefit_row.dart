import 'package:flutter/material.dart';


class PaywallBenefitRow extends StatelessWidget {
  const PaywallBenefitRow({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CheckGlyph(),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: Color(0xFF17141C),
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckGlyph extends StatelessWidget {
  const _CheckGlyph();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.circle, size: 20, color: const Color(0xFF0F9D8E).withValues(alpha: 0.12)),
          const Icon(Icons.check, size: 13, color: Color(0xFF0F9D8E)),
        ],
      ),
    );
  }
}
