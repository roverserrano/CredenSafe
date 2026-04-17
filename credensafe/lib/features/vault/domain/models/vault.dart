class Vault {
  Vault({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.vaultKeyEnvelope,
    required this.vaultKeyEnvelopeNonce,
    required this.kdfAlgorithm,
    required this.kdfSalt,
    required this.kdfMemoryKiB,
    required this.kdfIterations,
    required this.kdfParallelism,
    required this.cipherAlgorithm,
    required this.isBiometricEnabled,
  });

  final String id;
  final String ownerId;
  final String name;
  final String vaultKeyEnvelope;
  final String vaultKeyEnvelopeNonce;
  final String kdfAlgorithm;
  final String kdfSalt;
  final int kdfMemoryKiB;
  final int kdfIterations;
  final int kdfParallelism;
  final String cipherAlgorithm;
  final bool isBiometricEnabled;

  factory Vault.fromMap(Map<String, dynamic> map, {bool biometric = false}) {
    return Vault(
      id: map['id'] as String,
      ownerId: map['owner_id'] as String,
      name: map['name'] as String,
      vaultKeyEnvelope: map['vault_key_envelope'] as String,
      vaultKeyEnvelopeNonce: map['vault_key_envelope_nonce'] as String,
      kdfAlgorithm: map['kdf_algorithm'] as String,
      kdfSalt: map['kdf_salt'] as String,
      kdfMemoryKiB: map['kdf_memory_kib'] as int,
      kdfIterations: map['kdf_iterations'] as int,
      kdfParallelism: map['kdf_parallelism'] as int,
      cipherAlgorithm: map['cipher_algorithm'] as String,
      isBiometricEnabled: biometric,
    );
  }
}
