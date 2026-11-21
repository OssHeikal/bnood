import 'package:bnood/core/utils/safe_external_url.dart';

class AppPaywallContact {
  const AppPaywallContact({
    this.whatsappPhone,
    this.messageTemplate,
    this.whatsappUrl,
    this.contactUrl,
  });

  final String? whatsappPhone;
  final String? messageTemplate;
  final String? whatsappUrl;
  final String? contactUrl;

  static AppPaywallContact? fromJson(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    return AppPaywallContact(
      whatsappPhone: raw['whatsapp_phone'] as String?,
      messageTemplate: raw['message_template'] as String?,
      whatsappUrl: raw['whatsapp_url'] as String?,
      contactUrl: raw['contact_url'] as String?,
    );
  }
}

String applyPaywallContactPlaceholders(
  String template, {
  required String plan,
  required String period,
  String? userName,
  String? phone,
}) {
  var out = template;
  final values = <String, String>{
    'plan': plan,
    'period': period,
    'user_name': userName?.trim() ?? '',
    'phone': phone?.trim() ?? '',
  };
  for (final entry in values.entries) {
    out = out.replaceAll('{${entry.key}}', entry.value);
  }
  return out;
}

Future<bool> launchPaywallContact({
  required AppPaywallContact? contact,
  required String? legacyContactUrl,
  required String planName,
  required String periodLabel,
  String? userName,
  String? userPhone,
}) async {
  final phone = contact?.whatsappPhone?.trim();
  final template = contact?.messageTemplate?.trim();

  if (phone != null && phone.isNotEmpty && template != null && template.isNotEmpty) {
  var message = applyPaywallContactPlaceholders(
      template,
      plan: planName,
      period: periodLabel,
      userName: userName,
      phone: userPhone,
    );
    if (message.contains('{period}')) {
      message = message.replaceAll('{period}', periodLabel);
    }
    final url = 'https://wa.me/$phone?text=${Uri.encodeComponent(message)}';
    if (await launchAllowedUrl(url)) return true;
  }

  final fallback = contact?.whatsappUrl?.trim().isNotEmpty == true
      ? contact!.whatsappUrl!
      : (contact?.contactUrl?.trim().isNotEmpty == true
          ? contact!.contactUrl!
          : legacyContactUrl?.trim());

  if (fallback != null && fallback.isNotEmpty) {
    var url = fallback;
    if (url.contains('{period}')) {
      url = url.replaceAll('{period}', Uri.encodeComponent(periodLabel));
    }
    return launchAllowedUrl(url);
  }

  return false;
}