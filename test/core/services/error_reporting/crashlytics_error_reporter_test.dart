import 'package:bnood/core/services/error_reporting/crashlytics_client.dart';
import 'package:bnood/core/services/error_reporting/crashlytics_error_reporter.dart';
import 'package:bnood/core/services/error_reporting/error_reporting_user.dart';
import 'package:bnood/core/services/error_reporting/error_reporting_user_keys.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeCrashlyticsClient implements CrashlyticsClient {
  final List<String> logs = [];
  final List<({Object error, bool fatal, String? reason})> errors = [];
  String? userId;
  final Map<String, Object> customKeys = {};

  @override
  Future<void> log(String message) async {
    logs.add(message);
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    String? reason,
  }) async {
    errors.add((error: error, fatal: fatal, reason: reason));
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    customKeys[key] = value;
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    userId = identifier;
  }
}

void main() {
  test('does not record when inactive', () {
    final client = FakeCrashlyticsClient();
    final reporter = CrashlyticsErrorReporter(
      client: client,
      isActive: () => false,
    );

    reporter.captureException(Exception('e'), StackTrace.empty, fatal: true);
    reporter.setUser(const ErrorReportingUser(id: '1', phone: '010'));

    expect(client.errors, isEmpty);
    expect(client.userId, isNull);
  });

  test('setUser maps id and login phone only when active', () {
    final client = FakeCrashlyticsClient();
    final reporter = CrashlyticsErrorReporter(
      client: client,
      isActive: () => true,
    );

    reporter.setUser(
      const ErrorReportingUser(
        id: 'usr-9',
        phone: '01055556666',
        name: 'Hidden',
      ),
    );

    expect(client.userId, 'usr-9');
    expect(client.customKeys[errorReportingLoginPhoneKey], '01055556666');
  });

  test('clearUser clears identifier and login phone key when active', () {
    final client = FakeCrashlyticsClient();
    final reporter = CrashlyticsErrorReporter(
      client: client,
      isActive: () => true,
    );

    reporter.setUser(const ErrorReportingUser(id: 'usr-9', phone: '010'));
    reporter.clearUser();

    expect(client.userId, '');
    expect(client.customKeys[errorReportingLoginPhoneKey], '');
  });

  test('captureException records error when active', () {
    final client = FakeCrashlyticsClient();
    final reporter = CrashlyticsErrorReporter(
      client: client,
      isActive: () => true,
    );
    final error = Exception('boom');

    reporter.captureException(
      error,
      StackTrace.empty,
      context: const {'screen': 'home'},
      fatal: true,
    );

    expect(client.errors, hasLength(1));
    expect(client.errors.single.error, error);
    expect(client.errors.single.fatal, isTrue);
    expect(client.errors.single.reason, 'screen=home');
  });
}
