import 'models/user.dart';

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
}

bool userNeedsProfileCompletion(User? user) {
  if (user == null) return false;
  return !user.hasCompleteName;
}

String authenticatedHomeFor(User user) {
  if (userNeedsProfileCompletion(user)) return AuthPaths.completeProfile;
  return '/clients';
}

const _localLedgerRoots = {
  '/home',
  '/directory',
  '/items',
};

bool isRemoteClientsLocation(String location) {
  if (location == '/clients') return true;
  return location.startsWith('/clients/');
}

bool isLocalLedgerLocation(String location) {
  if (isRemoteClientsLocation(location)) return false;
  if (_localLedgerRoots.contains(location)) return true;
  if (location.startsWith('/suppliers/')) return true;
  if (location.startsWith('/craftsmen/')) return true;
  return false;
}

bool isAuthFlowLocation(String location) {
  return location.startsWith('/auth/');
}
