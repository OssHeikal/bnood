import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'voucher_receipt_picker.dart';

/// Runs camera pick on a nested sheet route so the voucher modal stays mounted.
class VoucherCameraPickRoute extends StatefulWidget {
  const VoucherCameraPickRoute({super.key, this.picker});

  final VoucherReceiptPicker? picker;

  @override
  State<VoucherCameraPickRoute> createState() => _VoucherCameraPickRouteState();
}

class _VoucherCameraPickRouteState extends State<VoucherCameraPickRoute> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    final picker = widget.picker ?? VoucherReceiptPicker();
    XFile? file;
    VoucherReceiptPickException? error;
    try {
      file = await picker.pickCamera();
    } on VoucherReceiptPickException catch (e) {
      error = e;
    } catch (_) {
      error = null;
    }
    if (!mounted) return;
    Navigator.of(context).pop(VoucherCameraPickResult(file: file, error: error));
  }

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.transparent,
      child: SizedBox.expand(),
    );
  }
}

class VoucherCameraPickResult {
  const VoucherCameraPickResult({this.file, this.error});

  final XFile? file;
  final VoucherReceiptPickException? error;
}
