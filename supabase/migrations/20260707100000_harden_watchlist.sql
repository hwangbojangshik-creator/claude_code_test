-- Security-review hardening for the watchlist table.
-- Applied automatically if this repo is connected to Supabase, or paste into
-- the dashboard SQL editor to run it manually.

-- Bound the text columns: the anon key is public, so a scripted client could
-- otherwise insert megabytes of junk into its own rows and eat storage quota.
-- (ESPN athlete ids are short numerics; names comfortably fit in 100 chars.)
alter table public.watchlist
  add constraint watchlist_player_id_len
    check (char_length(player_id) between 1 and 20),
  add constraint watchlist_player_name_len
    check (char_length(player_name) between 1 and 100);

-- Fill user_id from the caller's own identity by default. The RLS `with check`
-- policy already rejects a forged user_id, but with a default the client never
-- needs to assert who it is in the first place.
alter table public.watchlist
  alter column user_id set default auth.uid();
