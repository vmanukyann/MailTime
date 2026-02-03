# MailTime

MailTime is a Flutter web application for creating multimedia time capsules that deliver messages to your future self.

## Setup

1. Install Flutter (stable channel) and ensure `flutter doctor` is clean.
2. Copy `.env.example` to `.env` and add your Supabase keys.
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run locally:
   ```bash
   flutter run -d chrome
   ```

## Environment Variables

```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## Supabase Setup

### Database Tables

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE capsules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content_text TEXT NOT NULL,
  delivery_date TIMESTAMP WITH TIME ZONE NOT NULL,
  is_delivered BOOLEAN DEFAULT FALSE,
  delivered_at TIMESTAMP WITH TIME ZONE,
  photo_url TEXT,
  video_url TEXT,
  audio_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_capsules_delivery ON capsules(delivery_date, is_delivered);
CREATE INDEX idx_capsules_user ON capsules(user_id);
```

### RLS Policies

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE capsules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own profile"
  ON users FOR ALL
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can view own capsules"
  ON capsules FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own capsules"
  ON capsules FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

### Storage Buckets

Create private buckets:

- `capsule-photos`
- `capsule-videos`
- `capsule-audio`

Folder structure:

```
capsule-photos/{user_id}/{capsule_id}_photo.{ext}
capsule-videos/{user_id}/{capsule_id}_video.{ext}
capsule-audio/{user_id}/{capsule_id}_audio.{ext}
```

### Edge Function: `deliver-capsules`

Deploy the function in `supabase/functions/deliver-capsules` and configure a cron job:

```
*/5 * * * *
```

### Optional: Account Deletion

The profile screen calls an Edge Function named `delete-account`. Add one that:

- Uses the service role key
- Deletes the user from `auth.users`
- Relies on `ON DELETE CASCADE` to clear capsules

## Content Storage

Rich text is stored as Quill Delta JSON in `content_text`. If you prefer HTML, add a conversion step before saving.

## Firebase Hosting

1. Build Flutter web:
   ```bash
   flutter build web
   ```
2. Deploy:
   ```bash
   firebase deploy --only hosting
   ```

The `firebase.json` file is included in the project root.

## Folder Structure

```
lib/
  config/
  models/
  screens/
  services/
  utils/
  widgets/
supabase/
  functions/
```
