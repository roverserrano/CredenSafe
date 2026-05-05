import 'dart:typed_data';

class VaultUnlockContext {
  VaultUnlockContext({required this.vaultId, required this.vaultKey});

  final String vaultId;
  final Uint8List vaultKey;
}
