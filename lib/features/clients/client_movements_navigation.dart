import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void pushClientMovements(BuildContext context, {required String clientId, String? itemId}) {
  final path = Uri(
    path: '/clients/$clientId/movements',
    queryParameters: itemId != null && itemId.isNotEmpty ? {'item_id': itemId} : null,
  ).toString();
  context.push(path);
}
