create extension if not exists "uuid-ossp";

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  avatar_url text,
  is_biometric_enabled boolean not null default false,
  is_mfa_enabled boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.vaults (
  id uuid primary key default uuid_generate_v4(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null default 'Bóveda principal',
  description text,
  vault_key_envelope text not null,
  vault_key_envelope_nonce text not null,
  kdf_algorithm text not null default 'argon2id',
  kdf_salt text not null,
  kdf_memory_kib integer not null,
  kdf_iterations integer not null,
  kdf_parallelism integer not null,
  cipher_algorithm text not null default 'xchacha20-poly1305',
  key_version integer not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint uq_vault_owner_name unique (owner_id, name)
);

create table if not exists public.credentials (
  id uuid primary key default uuid_generate_v4(),
  vault_id uuid not null references public.vaults(id) on delete cascade,
  app_name text not null,
  app_url text,
  category text,
  account_label text,
  login_hint text,
  email_hint text,
  phone_hint text,
  icon_name text,
  is_favorite boolean not null default false,
  sort_order integer not null default 0,
  last_accessed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.credential_secret_blobs (
  credential_id uuid primary key references public.credentials(id) on delete cascade,
  payload_encrypted text not null,
  payload_nonce text not null,
  payload_version integer not null default 1,
  cipher_algorithm text not null default 'xchacha20-poly1305',
  aad_json jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.devices (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references auth.users(id) on delete cascade,
  device_name text,
  platform text,
  app_version text,
  device_fingerprint_hash text not null,
  trusted boolean not null default false,
  trusted_at timestamptz,
  last_seen_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint uq_device_per_user unique (user_id, device_fingerprint_hash)
);

create table if not exists public.audit_logs (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  vault_id uuid references public.vaults(id) on delete set null,
  credential_id uuid references public.credentials(id) on delete set null,
  device_id uuid references public.devices(id) on delete set null,
  event_type text not null,
  event_status text not null default 'success',
  ip_hash text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id)
  values (new.id)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

create trigger trg_profiles_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

create trigger trg_vaults_updated_at
before update on public.vaults
for each row execute function public.set_updated_at();

create trigger trg_credentials_updated_at
before update on public.credentials
for each row execute function public.set_updated_at();

create trigger trg_credential_secret_blobs_updated_at
before update on public.credential_secret_blobs
for each row execute function public.set_updated_at();

create trigger trg_devices_updated_at
before update on public.devices
for each row execute function public.set_updated_at();

create index if not exists idx_vaults_owner_id on public.vaults(owner_id);
create index if not exists idx_credentials_vault_id on public.credentials(vault_id);
create index if not exists idx_devices_user_id on public.devices(user_id);
create index if not exists idx_audit_logs_user_id_created_at on public.audit_logs(user_id, created_at desc);

alter table public.profiles enable row level security;
alter table public.vaults enable row level security;
alter table public.credentials enable row level security;
alter table public.credential_secret_blobs enable row level security;
alter table public.devices enable row level security;
alter table public.audit_logs enable row level security;

create policy "profiles_select_own" on public.profiles
for select to authenticated
using ((select auth.uid()) = id);

create policy "profiles_insert_own" on public.profiles
for insert to authenticated
with check ((select auth.uid()) = id);

create policy "profiles_update_own" on public.profiles
for update to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

create policy "vaults_select_own" on public.vaults
for select to authenticated
using ((select auth.uid()) = owner_id);

create policy "vaults_insert_own" on public.vaults
for insert to authenticated
with check ((select auth.uid()) = owner_id);

create policy "vaults_update_own" on public.vaults
for update to authenticated
using ((select auth.uid()) = owner_id)
with check ((select auth.uid()) = owner_id);

create policy "vaults_delete_own" on public.vaults
for delete to authenticated
using ((select auth.uid()) = owner_id);

create policy "credentials_select_own" on public.credentials
for select to authenticated
using (
  exists (
    select 1 from public.vaults v
    where v.id = credentials.vault_id
      and v.owner_id = (select auth.uid())
  )
);

create policy "credentials_insert_own" on public.credentials
for insert to authenticated
with check (
  exists (
    select 1 from public.vaults v
    where v.id = credentials.vault_id
      and v.owner_id = (select auth.uid())
  )
);

create policy "credentials_update_own" on public.credentials
for update to authenticated
using (
  exists (
    select 1 from public.vaults v
    where v.id = credentials.vault_id
      and v.owner_id = (select auth.uid())
  )
)
with check (
  exists (
    select 1 from public.vaults v
    where v.id = credentials.vault_id
      and v.owner_id = (select auth.uid())
  )
);

create policy "credentials_delete_own" on public.credentials
for delete to authenticated
using (
  exists (
    select 1 from public.vaults v
    where v.id = credentials.vault_id
      and v.owner_id = (select auth.uid())
  )
);

create policy "credential_blobs_select_own" on public.credential_secret_blobs
for select to authenticated
using (
  exists (
    select 1
    from public.credentials c
    join public.vaults v on v.id = c.vault_id
    where c.id = credential_secret_blobs.credential_id
      and v.owner_id = (select auth.uid())
  )
);

create policy "credential_blobs_insert_own" on public.credential_secret_blobs
for insert to authenticated
with check (
  exists (
    select 1
    from public.credentials c
    join public.vaults v on v.id = c.vault_id
    where c.id = credential_secret_blobs.credential_id
      and v.owner_id = (select auth.uid())
  )
);

create policy "credential_blobs_update_own" on public.credential_secret_blobs
for update to authenticated
using (
  exists (
    select 1
    from public.credentials c
    join public.vaults v on v.id = c.vault_id
    where c.id = credential_secret_blobs.credential_id
      and v.owner_id = (select auth.uid())
  )
)
with check (
  exists (
    select 1
    from public.credentials c
    join public.vaults v on v.id = c.vault_id
    where c.id = credential_secret_blobs.credential_id
      and v.owner_id = (select auth.uid())
  )
);

create policy "devices_select_own" on public.devices
for select to authenticated
using ((select auth.uid()) = user_id);

create policy "devices_insert_own" on public.devices
for insert to authenticated
with check ((select auth.uid()) = user_id);

create policy "devices_update_own" on public.devices
for update to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "audit_logs_select_own" on public.audit_logs
for select to authenticated
using ((select auth.uid()) = user_id);

create policy "audit_logs_insert_own" on public.audit_logs
for insert to authenticated
with check ((select auth.uid()) = user_id);
