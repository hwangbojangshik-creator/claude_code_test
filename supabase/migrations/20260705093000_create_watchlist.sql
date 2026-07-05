-- Fairway golf tracker: per-user player watchlist
-- Applied automatically by Supabase when this file is pushed to the connected GitHub repo,
-- or paste it into the Supabase dashboard SQL editor to run it manually.

create table if not exists public.watchlist (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references auth.users(id) on delete cascade,
  player_id   text not null,          -- ESPN athlete id
  player_name text not null,          -- denormalized so we can show names without a join
  created_at  timestamptz not null default now(),
  unique (user_id, player_id)         -- a player can be starred once per user
);

-- Row Level Security: each user can only see and change their OWN rows.
-- The public anon key can reach this table, but these policies are what actually
-- keep one user's watchlist private from everyone else.
alter table public.watchlist enable row level security;

create policy "select own watchlist"
  on public.watchlist for select
  using (auth.uid() = user_id);

create policy "insert own watchlist"
  on public.watchlist for insert
  with check (auth.uid() = user_id);

create policy "delete own watchlist"
  on public.watchlist for delete
  using (auth.uid() = user_id);

-- Fast lookups of "my players".
create index if not exists watchlist_user_idx on public.watchlist (user_id);
