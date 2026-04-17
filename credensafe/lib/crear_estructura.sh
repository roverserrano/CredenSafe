#!/bin/bash

BASE="/home/spartano/Documentos/ClaveSegura/CredenSafe/credensafe/lib"

echo "📁 Creando estructura de carpetas..."

# APP

mkdir -p $BASE/app

# CORE

mkdir -p $BASE/core/config
mkdir -p $BASE/core/crypto
mkdir -p $BASE/core/errors
mkdir -p $BASE/core/utils

# FEATURES - AUTH

mkdir -p $BASE/features/auth/data/services
mkdir -p $BASE/features/auth/data/repositories
mkdir -p $BASE/features/auth/domain/models
mkdir -p $BASE/features/auth/domain/repositories
mkdir -p $BASE/features/auth/presentation/viewmodels
mkdir -p $BASE/features/auth/presentation/views

# FEATURES - VAULT

mkdir -p $BASE/features/vault/data/services
mkdir -p $BASE/features/vault/data/repositories
mkdir -p $BASE/features/vault/domain/models
mkdir -p $BASE/features/vault/domain/repositories
mkdir -p $BASE/features/vault/presentation/viewmodels
mkdir -p $BASE/features/vault/presentation/views

# FEATURES - CREDENTIALS

mkdir -p $BASE/features/credentials/data/services
mkdir -p $BASE/features/credentials/data/repositories
mkdir -p $BASE/features/credentials/domain/models
mkdir -p $BASE/features/credentials/domain/repositories
mkdir -p $BASE/features/credentials/presentation/viewmodels
mkdir -p $BASE/features/credentials/presentation/views

# FEATURES - AUDIT

mkdir -p $BASE/features/audit/data/services
mkdir -p $BASE/features/audit/data/repositories
mkdir -p $BASE/features/audit/domain/repositories
mkdir -p $BASE/features/audit/presentation/viewmodels
mkdir -p $BASE/features/audit/presentation/views

echo "📄 Creando archivos..."

# APP

touch $BASE/app/app.dart
touch $BASE/app/routes.dart
touch $BASE/app/di.dart

# CORE

touch $BASE/core/config/supabase_config.dart

touch $BASE/core/crypto/key_derivation_service.dart
touch $BASE/core/crypto/encryption_service.dart
touch $BASE/core/crypto/biometric_gate_service.dart
touch $BASE/core/crypto/secure_key_store_service.dart

touch $BASE/core/errors/app_exceptions.dart

touch $BASE/core/utils/mask_utils.dart
touch $BASE/core/utils/validators.dart

# AUTH

touch $BASE/features/auth/data/services/auth_remote_service.dart
touch $BASE/features/auth/data/repositories/auth_repository_impl.dart
touch $BASE/features/auth/domain/models/app_user.dart
touch $BASE/features/auth/domain/repositories/auth_repository.dart
touch $BASE/features/auth/presentation/viewmodels/login_viewmodel.dart
touch $BASE/features/auth/presentation/viewmodels/register_viewmodel.dart
touch $BASE/features/auth/presentation/views/login_page.dart
touch $BASE/features/auth/presentation/views/register_page.dart

# VAULT

touch $BASE/features/vault/data/services/vault_remote_service.dart
touch $BASE/features/vault/data/services/vault_local_service.dart
touch $BASE/features/vault/data/repositories/vault_repository_impl.dart
touch $BASE/features/vault/domain/models/vault.dart
touch $BASE/features/vault/domain/models/vault_unlock_context.dart
touch $BASE/features/vault/domain/repositories/vault_repository.dart
touch $BASE/features/vault/presentation/viewmodels/unlock_vault_viewmodel.dart
touch $BASE/features/vault/presentation/viewmodels/vault_list_viewmodel.dart
touch $BASE/features/vault/presentation/views/unlock_vault_page.dart
touch $BASE/features/vault/presentation/views/vault_list_page.dart

# CREDENTIALS

touch $BASE/features/credentials/data/services/credential_remote_service.dart
touch $BASE/features/credentials/data/services/credential_local_service.dart
touch $BASE/features/credentials/data/repositories/credential_repository_impl.dart
touch $BASE/features/credentials/domain/models/credential_metadata.dart
touch $BASE/features/credentials/domain/models/decrypted_credential.dart
touch $BASE/features/credentials/domain/repositories/credential_repository.dart
touch $BASE/features/credentials/presentation/viewmodels/credential_list_viewmodel.dart
touch $BASE/features/credentials/presentation/viewmodels/credential_detail_viewmodel.dart
touch $BASE/features/credentials/presentation/viewmodels/credential_form_viewmodel.dart
touch $BASE/features/credentials/presentation/views/credential_list_page.dart
touch $BASE/features/credentials/presentation/views/credential_detail_page.dart
touch $BASE/features/credentials/presentation/views/credential_form_page.dart

# AUDIT

touch $BASE/features/audit/data/services/audit_remote_service.dart
touch $BASE/features/audit/data/repositories/audit_repository_impl.dart
touch $BASE/features/audit/domain/repositories/audit_repository.dart
touch $BASE/features/audit/presentation/viewmodels/security_activity_viewmodel.dart
touch $BASE/features/audit/presentation/views/security_activity_page.dart

echo "✅ Estructura creada correctamente"
