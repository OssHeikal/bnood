abstract final class AuthPaths {
  static const bootstrap = '/auth/bootstrap';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const registerVerify = '/auth/register/verify';
  static const forgotPassword = '/auth/forgot-password';
  static const forgotVerify = '/auth/forgot-password/verify';
  static const resetPassword = '/auth/reset-password';
  static const changePassword = '/auth/change-password';
  static const remote = '/remote';
}

const _localLedgerRoots = {
  '/home',
  '/clients',
  '/directory',
  '/items',
};

bool isLocalLedgerLocation(String location) {
  if (_localLedgerRoots.contains(location)) return true;
  if (location.startsWith('/clients/')) return true;
  if (location.startsWith('/suppliers/')) return true;
  if (location.startsWith('/craftsmen/')) return true;
  return false;
}

bool isAuthFlowLocation(String location) {
  return location.startsWith('/auth/');
}
