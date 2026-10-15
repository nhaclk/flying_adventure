# Flying Adventure

A Flutter + Flame flying game with three playable characters.

## Run locally

Install the [Flutter SDK](https://docs.flutter.dev/get-started/install), then run:

```bash
flutter pub get
flutter run -d chrome --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR-PUBLISHABLE-KEY
```

The same Supabase project URL and publishable key are required
for mobile builds. These are public client values, not secrets; never use a
Supabase service-role key in the app.

## Set up the global leaderboard

The app stores new scores in Supabase, so everyone sees the same Top 10.
Existing scores saved on individual devices are not uploaded automatically.

1. Create a project at [Supabase](https://supabase.com/dashboard).
2. In the project's **SQL Editor**, run this setup script:

   ```sql
   create table if not exists public.scores (
     id bigint generated always as identity primary key,
     name text not null check (char_length(name) between 1 and 12),
     score integer not null check (score > 0),
     created_at timestamptz not null default now()
   );

   alter table public.scores enable row level security;

   drop policy if exists "Scores are readable by everyone" on public.scores;
   create policy "Scores are readable by everyone"
     on public.scores for select to anon, authenticated using (true);

   revoke all on table public.scores from public, anon, authenticated;
   grant select on table public.scores to anon, authenticated;

   create or replace function public.submit_score(
     player_name text,
     player_score integer
   )
   returns boolean
   language plpgsql
   security definer
   set search_path = ''
   as $$
   declare
     normalized_name text := coalesce(
       nullif(left(btrim(player_name), 12), ''),
       'PLAYER'
     );
     top_scores_count integer;
     cutoff_score integer;
   begin
     if player_score is null or player_score <= 0 then
       raise exception 'Score must be positive';
     end if;

     lock table public.scores in exclusive mode;

     select count(*), min(score)
       into top_scores_count, cutoff_score
       from (
         select score
           from public.scores
           order by score desc, created_at, id
           limit 10
       ) as top_scores;

     if top_scores_count >= 10 and player_score <= cutoff_score then
       return false;
     end if;

     insert into public.scores (name, score)
       values (normalized_name, player_score);

     delete from public.scores
       where id in (
         select id
           from (
             select id, row_number() over (
               order by score desc, created_at, id
             ) as rank
               from public.scores
           ) as ranked_scores
           where rank > 10
       );

     return true;
   end;
   $$;

   revoke all on function public.submit_score(text, integer)
     from public, anon, authenticated;
   grant execute on function public.submit_score(text, integer)
     to anon, authenticated;
   ```

3. In **Project Settings → API Keys**, copy the **Project URL** and the public
   **publishable key**. Do not use the service-role key.
4. In your GitHub repository, open **Settings → Secrets and variables →
   Actions → Variables**, then add:
   - `SUPABASE_URL` — the Project URL
   - `SUPABASE_PUBLISHABLE_KEY` — the publishable key

   These client values are included in the public web app; database access is
   protected by the table permissions and row-level security above.

Scores are submitted anonymously, so the database can enforce valid names,
positive scores, and a bounded Top 10, but cannot verify that a submitted score
was earned fairly by the game client.

## Publish on GitHub Pages

The workflow in `.github/workflows/deploy.yml` builds and publishes the game
when code is pushed to `main` or `master`. It also supports manual deployments
from the Actions tab and automatically sets the correct base path for project
sites and `username.github.io` user sites.

1. Commit and push the workflow to this repository:

   ```bash
   git add .github/workflows/deploy.yml README.md pubspec.yaml pubspec.lock lib/main.dart lib/services/score_service.dart lib/screens/game_screen.dart lib/screens/leaderboard_screen.dart
   git commit -m "Add global Supabase leaderboard"
   git push origin main
   ```

2. Open [Settings → Pages](https://github.com/nhaclk/flying_adventure/settings/pages).
   Under **Build and deployment → Source**, select **GitHub Actions**.
3. Open the **Actions** tab and wait for **Deploy to GitHub Pages** to complete
   successfully.
4. Visit **https://nhaclk.github.io/flying_adventure/**. The first deployment
   can take a few minutes to become available.

Future pushes to `main` (or `master`) publish updates automatically. To deploy
without a new push, open **Actions → Deploy to GitHub Pages → Run workflow**.

## Build for web locally

To build locally with the same project-site path:

```bash
flutter build web --release --base-href /flying_adventure/ --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR-PUBLISHABLE-KEY
```
