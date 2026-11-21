import 'package:flutter/material.dart';

export 'profit_percentage_sheet.dart';
import 'profit_percentage_sheet.dart';

typedef EngineerFeeSheet = ProfitPercentageSheet;

Future<void> showEngineerFeeSheet({
  required BuildContext context,
  required String clientId,
  required String projectId,
  required String clientName,
  int? engineerBasisPoints,
}) =>
    showProfitPercentageSheet(
      context: context,
      clientId: clientId,
      projectId: projectId,
      clientName: clientName,
      engineerBasisPoints: engineerBasisPoints,
    );
