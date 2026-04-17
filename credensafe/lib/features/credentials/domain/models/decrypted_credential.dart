class DecryptedCredential {
  DecryptedCredential({
    this.id,
    required this.appName,
    this.appUrl,
    this.category,
    this.accountLabel,
    this.email,
    this.username,
    this.password,
    this.phoneNumber,
    this.securityCode,
    this.recoveryEmail,
    this.recoveryPhone,
    this.notes,
    this.isFavorite = false,
    this.customFields = const <Map<String, String>>[],
  });

  final String? id;
  final String appName;
  final String? appUrl;
  final String? category;
  final String? accountLabel;
  final String? email;
  final String? username;
  final String? password;
  final String? phoneNumber;
  final String? securityCode;
  final String? recoveryEmail;
  final String? recoveryPhone;
  final String? notes;
  final bool isFavorite;
  final List<Map<String, String>> customFields;

  Map<String, dynamic> toSensitiveJson() {
    return {
      'email': email,
      'username': username,
      'password': password,
      'phoneNumber': phoneNumber,
      'securityCode': securityCode,
      'recoveryEmail': recoveryEmail,
      'recoveryPhone': recoveryPhone,
      'notes': notes,
      'customFields': customFields,
    };
  }

  factory DecryptedCredential.fromParts({
    required String id,
    required Map<String, dynamic> metadata,
    required Map<String, dynamic> sensitive,
  }) {
    return DecryptedCredential(
      id: id,
      appName: metadata['app_name'] as String,
      appUrl: metadata['app_url'] as String?,
      category: metadata['category'] as String?,
      accountLabel: metadata['account_label'] as String?,
      isFavorite: (metadata['is_favorite'] as bool?) ?? false,
      email: sensitive['email'] as String?,
      username: sensitive['username'] as String?,
      password: sensitive['password'] as String?,
      phoneNumber: sensitive['phoneNumber'] as String?,
      securityCode: sensitive['securityCode'] as String?,
      recoveryEmail: sensitive['recoveryEmail'] as String?,
      recoveryPhone: sensitive['recoveryPhone'] as String?,
      notes: sensitive['notes'] as String?,
      customFields: (sensitive['customFields'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((item) => item.map(
                (key, value) => MapEntry(key.toString(), value.toString()),
              ))
          .toList(),
    );
  }
}
