import 'dart:typed_data';

import 'package:bnood/features/vouchers/voucher_camera_pick_route.dart';
import 'package:bnood/features/vouchers/voucher_receipt_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

class _VoucherHost extends StatelessWidget {
  const _VoucherHost();

  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('voucher'));
}

class _FakePicker extends VoucherReceiptPicker {
  _FakePicker(this._file);

  final XFile? _file;

  @override
  Future<XFile?> pickCamera({int imageQuality = 85}) async => _file;
}

void main() {
  testWidgets('camera route cancel pops null file and keeps voucher layer', (tester) async {
    VoucherCameraPickResult? popped;

    await tester.pumpWidget(
      MaterialApp(
        home: Navigator(
          onPopPage: (route, result) {
            if (!route.didPop(result)) return false;
            popped = result as VoucherCameraPickResult?;
            return true;
          },
          pages: [const MaterialPage(child: _VoucherHost())],
        ),
      ),
    );

    final hostContext = tester.element(find.byType(_VoucherHost));
    final routeFuture = Navigator.of(hostContext).push<VoucherCameraPickResult>(
      PageRouteBuilder(opaque: false, pageBuilder: (_, _, _) => VoucherCameraPickRoute(picker: _FakePicker(null))),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final poppedResult = await routeFuture.timeout(const Duration(seconds: 2));
    popped = poppedResult;

    expect(popped, isNotNull);
    expect(popped!.file, isNull);
    expect(popped!.error, isNull);
    expect(find.byType(_VoucherHost), findsOneWidget);
  });

  testWidgets('camera route success returns file without dismissing host', (tester) async {
    VoucherCameraPickResult? popped;
    final xfile = XFile.fromData(Uint8List.fromList([1, 2, 3]), name: 'r.jpg');

    await tester.pumpWidget(
      MaterialApp(
        home: Navigator(
          onPopPage: (route, result) {
            if (!route.didPop(result)) return false;
            popped = result as VoucherCameraPickResult?;
            return true;
          },
          pages: [const MaterialPage(child: _VoucherHost())],
        ),
      ),
    );

    final hostContext = tester.element(find.byType(_VoucherHost));
    final routeFuture = Navigator.of(hostContext).push<VoucherCameraPickResult>(
      PageRouteBuilder(opaque: false, pageBuilder: (_, _, _) => VoucherCameraPickRoute(picker: _FakePicker(xfile))),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    popped = await routeFuture.timeout(const Duration(seconds: 2));

    expect(popped?.file, isNotNull);
    expect(find.byType(_VoucherHost), findsOneWidget);
  });

  testWidgets('camera route pops without closing parent navigator', (tester) async {
    var parentAlive = true;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Navigator(
                onPopPage: (route, result) {
                  if (!route.didPop(result)) return false;
                  return true;
                },
                pages: [
                  MaterialPage(
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          await Navigator.of(context).push<VoucherCameraPickResult>(
                            PageRouteBuilder(
                              opaque: false,
                              pageBuilder: (_, _, _) => VoucherCameraPickRoute(picker: _FakePicker(null)),
                            ),
                          );
                        },
                        child: const Text('camera'),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('camera'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(parentAlive, isTrue);
    expect(find.text('camera'), findsOneWidget);
  });
}
