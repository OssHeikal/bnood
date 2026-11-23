import 'package:bnood/features/auth/models/user.dart';

abstract final class AuthPaths {
  static const bootstrap = '/auth/bootstrap';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const registerVerify = '/auth/register/verify';
  static const completeProfile = '/auth/complete-profile';
  static const forgotPassword = '/auth/forgot-password';
  static const forgotVerify = '/auth/forgot-password/verify';
  static const resetPassword = '/auth/reset-password';
  static const changePassword = '/auth/change-password';
  static const remote = '/remote';
  static const profile = '/profile';
  static const settings = '/settings';
  static const more = '/more';
  static const preferences = '/settings/preferences';
  static const notifications = '/settings/notifications';
  static const notificationsInbox = '/notifications';
}

bool userNeedsProfileCompletion(User? user) {
  if (user == null) return false;
  return !user.hasCompleteName;
}

String authenticatedHomeFor(User user) {
  if (userNeedsProfileCompletion(user)) return AuthPaths.completeProfile;
  return '/home';
}

bool isRemoteClientsLocation(String location) {
  if (location == '/clients') return true;
  return location.startsWith('/clients/');
}

bool isRemoteProjectsLocation(String location) {
  return location == '/projects';
}

bool isRemoteItemsLocation(String location) {
  return location == '/items';
}

bool isRemoteDirectoryLocation(String location) {
  return location == '/directory';
}

bool isRemoteProviderDetailLocation(String location) {
  return location.startsWith('/providers/');
}

bool isLocalLedgerLocation(String location) {
  return false;
}

bool isAuthFlowLocation(String location) {
  return location.startsWith('/auth/');
}
