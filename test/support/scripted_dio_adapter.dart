import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Test [HttpClientAdapter] that returns scripted responses per request.
class ScriptedDioAdapter implements HttpClientAdapter {
  ScriptedDioAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) =>
      _handler(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(
  String body, {
  int statusCode = 200,
}) {
  return ResponseBody.fromString(
    body,
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

ResponseBody pdfResponse(
  List<int> bytes, {
  int statusCode = 200,
  String? contentDisposition,
}) {
  return ResponseBody.fromBytes(
    bytes,
    statusCode,
    headers: {
      Headers.contentTypeHeader: ['application/pdf'],
      if (contentDisposition != null) 'content-disposition': [contentDisposition],
    },
  );
}
