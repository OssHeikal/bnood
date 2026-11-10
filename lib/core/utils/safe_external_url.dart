import 'package:url_launcher/url_launcher.dart';

bool isAllowedExternalUrl(Uri uri) {
  final scheme = uri.scheme.toLowerCase();
  return scheme == 'http' ||
      scheme == 'https' ||
      scheme == 'mailto' ||
      scheme == 'tel';
}

bool isAllowedExternalUrlString(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  return isAllowedExternalUrl(uri);
}

Future<void> openStoreUrl(String? storeUrl) async {
  if (storeUrl == null || storeUrl.trim().isEmpty) return;
  final uri = Uri.tryParse(storeUrl);
  if (uri == null || !isAllowedExternalUrl(uri)) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<bool> launchAllowedUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null || !isAllowedExternalUrl(uri)) return false;
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
