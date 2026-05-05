enum LoginStatus {
  initial,
  validating,
  loading,
  authenticated,
  unauthenticated,
  error,
}

enum RegisterStatus {
  initial,
  validating,
  loading,
  success,
  confirmationRequired,
  error,
}

enum PasswordRecoveryStatus {
  initial,
  validating,
  loading,
  emailSent,
  success,
  error,
}

enum PasswordChangeStatus { initial, validating, loading, success, error }
