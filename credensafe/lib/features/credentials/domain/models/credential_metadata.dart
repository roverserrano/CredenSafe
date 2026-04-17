class CredentialMetadata {
  CredentialMetadata({
    required this.id,
    required this.vaultId,
    required this.appName,
    required this.appUrl,
    required this.category,
    required this.accountLabel,
    required this.loginHint,
    required this.emailHint,
    required this.phoneHint,
    required this.iconName,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String vaultId;
  final String appName;
  final String? appUrl;
  final String? category;
  final String? accountLabel;
  final String? loginHint;
  final String? emailHint;
  final String? phoneHint;
  final String? iconName;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CredentialMetadata.fromMap(Map<String, dynamic> map) {
    return CredentialMetadata(
      id: map['id'] as String,
      vaultId: map['vault_id'] as String,
      appName: map['app_name'] as String,
      appUrl: map['app_url'] as String?,
      category: map['category'] as String?,
      accountLabel: map['account_label'] as String?,
      loginHint: map['login_hint'] as String?,
      emailHint: map['email_hint'] as String?,
      phoneHint: map['phone_hint'] as String?,
      iconName: map['icon_name'] as String?,
      isFavorite: (map['is_favorite'] as bool?) ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
