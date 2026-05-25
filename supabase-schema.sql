-- ClipForge Pipeline Schema
-- Paste this into Supabase SQL Editor and click Run

CREATE TABLE IF NOT EXISTS cf_clips (
  id bigint generated always as identity primary key,
  source_video_id text not null,
  source_channel text not null,
  influencer text not null,
  clip_start integer not null,
  clip_end integer not null,
  posted_to_channel text not null,
  posted_video_id text,
  title text,
  views integer default 0,
  duration integer,
  status text default 'new',
  file_path text,
  error_message text,
  created_at timestamptz default now(),
  confirmed_at timestamptz,
  UNIQUE(source_video_id, clip_start, clip_end, posted_to_channel)
);

CREATE TABLE IF NOT EXISTS cf_influencers (
  id bigint generated always as identity primary key,
  name text not null unique,
  search_terms jsonb not null default '[]',
  status text default 'active',
  clips_count integer default 0,
  last_clipped_at timestamptz,
  created_at timestamptz default now()
);

CREATE TABLE IF NOT EXISTS cf_channels (
  id bigint generated always as identity primary key,
  name text not null unique,
  youtube_id text,
  subscribers integer default 0,
  total_views bigint default 0,
  total_clips integer default 0,
  status text default 'active',
  token_status text default 'valid',
  last_upload_at timestamptz,
  created_at timestamptz default now()
);

CREATE TABLE IF NOT EXISTS cf_pipeline_runs (
  id bigint generated always as identity primary key,
  started_at timestamptz default now(),
  finished_at timestamptz,
  status text default 'running',
  clips_uploaded integer default 0,
  clips_failed integer default 0,
  error_log text,
  duration_seconds integer,
  channel text,
  influencer text
);

CREATE TABLE IF NOT EXISTS cf_settings (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz default now()
);

ALTER TABLE cf_clips ENABLE ROW LEVEL SECURITY;
ALTER TABLE cf_influencers ENABLE ROW LEVEL SECURITY;
ALTER TABLE cf_channels ENABLE ROW LEVEL SECURITY;
ALTER TABLE cf_pipeline_runs ENABLE ROW LEVEL SECURITY;
ALTER TABLE cf_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read access" ON cf_clips FOR SELECT USING (true);
CREATE POLICY "Public insert access" ON cf_clips FOR INSERT WITH CHECK (true);
CREATE POLICY "Public update access" ON cf_clips FOR UPDATE USING (true);
CREATE POLICY "Public delete access" ON cf_clips FOR DELETE USING (true);

CREATE POLICY "Public read access" ON cf_influencers FOR SELECT USING (true);
CREATE POLICY "Public insert access" ON cf_influencers FOR INSERT WITH CHECK (true);
CREATE POLICY "Public update access" ON cf_influencers FOR UPDATE USING (true);
CREATE POLICY "Public delete access" ON cf_influencers FOR DELETE USING (true);

CREATE POLICY "Public read access" ON cf_channels FOR SELECT USING (true);
CREATE POLICY "Public insert access" ON cf_channels FOR INSERT WITH CHECK (true);
CREATE POLICY "Public update access" ON cf_channels FOR UPDATE USING (true);

CREATE POLICY "Public read access" ON cf_pipeline_runs FOR SELECT USING (true);
CREATE POLICY "Public insert access" ON cf_pipeline_runs FOR INSERT WITH CHECK (true);
CREATE POLICY "Public update access" ON cf_pipeline_runs FOR UPDATE USING (true);

CREATE POLICY "Public read access" ON cf_settings FOR SELECT USING (true);
CREATE POLICY "Public insert access" ON cf_settings FOR INSERT WITH CHECK (true);
CREATE POLICY "Public update access" ON cf_settings FOR UPDATE USING (true);

CREATE INDEX IF NOT EXISTS idx_cf_clips_status ON cf_clips(status);
CREATE INDEX IF NOT EXISTS idx_cf_clips_channel ON cf_clips(posted_to_channel);
CREATE INDEX IF NOT EXISTS idx_cf_clips_created ON cf_clips(created_at desc);
CREATE INDEX IF NOT EXISTS idx_cf_clips_influencer ON cf_clips(influencer);
CREATE INDEX IF NOT EXISTS idx_cf_influencers_status ON cf_influencers(status);
CREATE INDEX IF NOT EXISTS idx_cf_pipeline_runs_started ON cf_pipeline_runs(started_at desc);

INSERT INTO cf_settings (key, value) VALUES
  ('clips_per_run', '1'),
  ('runs_per_day', '3'),
  ('clip_duration', '60'),
  ('max_video_length', '1200'),
  ('edit_intensity', '"medium"'),
  ('auto_update_ytdlp', 'true'),
  ('auto_cleanup', 'true'),
  ('schedule_times', '"08:00,14:00,20:00"'),
  ('timezone', '"America/Edmonton"')
ON CONFLICT (key) DO NOTHING;
