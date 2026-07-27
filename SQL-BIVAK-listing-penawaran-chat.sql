-- ============================================================
-- BIVAK · Tahap G lanjutan
-- Tabel listing, penawaran, pesan + RLS
-- Aman dijalankan ulang (idempotent)
-- Jalankan di: Supabase Dashboard > SQL Editor > New query > Run
-- ============================================================

-- ---------- 1. LISTING (barang yang dibarterkan) ----------
create table if not exists public.barter_listings (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  category text not null,
  condition text,
  appraised_value bigint not null default 0,
  city text,
  description text,
  wants jsonb default '[]'::jsonb,
  status text not null default 'aktif',
  photos jsonb default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists barter_listings_owner_idx on public.barter_listings(owner_id);
create index if not exists barter_listings_status_idx on public.barter_listings(status);

alter table public.barter_listings enable row level security;

drop policy if exists "listing dapat dibaca pengguna login" on public.barter_listings;
create policy "listing dapat dibaca pengguna login"
  on public.barter_listings for select to authenticated using (true);

drop policy if exists "buat listing sendiri" on public.barter_listings;
create policy "buat listing sendiri"
  on public.barter_listings for insert to authenticated with check (auth.uid() = owner_id);

drop policy if exists "ubah listing sendiri" on public.barter_listings;
create policy "ubah listing sendiri"
  on public.barter_listings for update to authenticated
  using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

drop policy if exists "hapus listing sendiri" on public.barter_listings;
create policy "hapus listing sendiri"
  on public.barter_listings for delete to authenticated using (auth.uid() = owner_id);

-- ---------- 2. PENAWARAN ----------
create table if not exists public.barter_offers (
  id uuid primary key default gen_random_uuid(),
  target_listing_id uuid not null references public.barter_listings(id) on delete cascade,
  proposer_id uuid not null references auth.users(id) on delete cascade,
  items jsonb default '[]'::jsonb,
  cash_adjustment bigint default 0,
  note text,
  status text not null default 'Diajukan',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists barter_offers_target_idx on public.barter_offers(target_listing_id);
create index if not exists barter_offers_proposer_idx on public.barter_offers(proposer_id);

alter table public.barter_offers enable row level security;

-- fungsi bantu: apakah user boleh melihat penawaran ini
create or replace function public.can_see_offer(offer uuid)
returns boolean language sql security definer stable set search_path = public as $$
  select exists (
    select 1 from public.barter_offers o
    join public.barter_listings l on l.id = o.target_listing_id
    where o.id = offer and (o.proposer_id = auth.uid() or l.owner_id = auth.uid())
  );
$$;

drop policy if exists "lihat penawaran yang melibatkan saya" on public.barter_offers;
create policy "lihat penawaran yang melibatkan saya"
  on public.barter_offers for select to authenticated
  using (
    proposer_id = auth.uid()
    or exists (select 1 from public.barter_listings l where l.id = target_listing_id and l.owner_id = auth.uid())
  );

drop policy if exists "ajukan penawaran sendiri" on public.barter_offers;
create policy "ajukan penawaran sendiri"
  on public.barter_offers for insert to authenticated with check (proposer_id = auth.uid());

drop policy if exists "ubah penawaran yang melibatkan saya" on public.barter_offers;
create policy "ubah penawaran yang melibatkan saya"
  on public.barter_offers for update to authenticated
  using (
    proposer_id = auth.uid()
    or exists (select 1 from public.barter_listings l where l.id = target_listing_id and l.owner_id = auth.uid())
  )
  with check (
    proposer_id = auth.uid()
    or exists (select 1 from public.barter_listings l where l.id = target_listing_id and l.owner_id = auth.uid())
  );

-- ---------- 3. PESAN / CHAT NEGOSIASI ----------
create table if not exists public.barter_messages (
  id uuid primary key default gen_random_uuid(),
  offer_id uuid not null references public.barter_offers(id) on delete cascade,
  from_id uuid references auth.users(id) on delete set null,
  from_label text,
  body text not null,
  at timestamptz not null default now()
);

create index if not exists barter_messages_offer_idx on public.barter_messages(offer_id, at);

alter table public.barter_messages enable row level security;

drop policy if exists "baca pesan penawaran saya" on public.barter_messages;
create policy "baca pesan penawaran saya"
  on public.barter_messages for select to authenticated using (public.can_see_offer(offer_id));

drop policy if exists "kirim pesan di penawaran saya" on public.barter_messages;
create policy "kirim pesan di penawaran saya"
  on public.barter_messages for insert to authenticated
  with check (public.can_see_offer(offer_id) and (from_id = auth.uid() or from_id is null));

drop policy if exists "ubah pesan saya" on public.barter_messages;
create policy "ubah pesan saya"
  on public.barter_messages for update to authenticated
  using (public.can_see_offer(offer_id)) with check (public.can_see_offer(offer_id));

-- ---------- 4. TRANSAKSI & LAPORAN ----------
create table if not exists public.barter_transactions (
  id uuid primary key default gen_random_uuid(),
  offer_id uuid not null references public.barter_offers(id) on delete cascade,
  status text not null default 'selesai',
  agreed_at timestamptz,
  completed_at timestamptz default now()
);
alter table public.barter_transactions enable row level security;
drop policy if exists "lihat transaksi saya" on public.barter_transactions;
create policy "lihat transaksi saya"
  on public.barter_transactions for select to authenticated using (public.can_see_offer(offer_id));
drop policy if exists "catat transaksi saya" on public.barter_transactions;
create policy "catat transaksi saya"
  on public.barter_transactions for insert to authenticated with check (public.can_see_offer(offer_id));

create table if not exists public.barter_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references auth.users(id) on delete cascade,
  target_type text not null,
  target_id text not null,
  reason text,
  status text not null default 'baru',
  created_at timestamptz not null default now()
);
alter table public.barter_reports enable row level security;
drop policy if exists "kirim laporan" on public.barter_reports;
create policy "kirim laporan"
  on public.barter_reports for insert to authenticated with check (reporter_id = auth.uid());
drop policy if exists "lihat laporan saya" on public.barter_reports;
create policy "lihat laporan saya"
  on public.barter_reports for select to authenticated using (reporter_id = auth.uid());

-- ---------- 5. VERIFIKASI ----------
select table_name from information_schema.tables
where table_schema = 'public' and table_name like 'barter%'
order by table_name;
