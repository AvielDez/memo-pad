CREATE TYPE theme AS ENUM ('LIGHT', 'DARK');
CREATE TYPE font_type AS ENUM ('SANS_SERIF', 'SERIF', 'MONOSPACE');

CREATE SCHEMA IF NOT EXISTS extensions;

CREATE OR REPLACE FUNCTION extensions.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;



create table app_user (
    id UUID PRIMARY KEY DEFAULT auth.uid(),
    email TEXT UNIQUE NOT NULL,
    last_login TIMESTAMPTZ NOT NULL DEFAULT now(),
    is_verified BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);


create table user_profile (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name TEXT NOT NULL,
    setting_theme theme NOT NULL DEFAULT 'LIGHT',
    setting_font_type font_type NOT NULL DEFAULT 'SANS_SERIF',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    user_id UUID UNIQUE REFERENCES app_user(id) ON DELETE CASCADE
);

create table note (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    is_archived BOOLEAN NOT NULL DEFAULT false,
    user_id UUID REFERENCES app_user(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

create table tag (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    user_id UUID REFERENCES app_user(id) ON DELETE CASCADE
);

create table note_tag (
    note_id UUID REFERENCES note(id) ON DELETE CASCADE,
    tag_id UUID REFERENCES tag(id) ON DELETE CASCADE,
    user_id UUID REFERENCES app_user(id) ON DELETE CASCADE,
    PRIMARY KEY (note_id, tag_id, user_id)
);

-- Triggers to set updated_at on each table
CREATE TRIGGER set_app_user_updated_at
BEFORE UPDATE ON app_user
FOR EACH ROW
EXECUTE PROCEDURE extensions.set_updated_at();

CREATE TRIGGER set_user_profile_updated_at
BEFORE UPDATE ON user_profile
FOR EACH ROW
EXECUTE PROCEDURE extensions.set_updated_at();

CREATE TRIGGER set_note_updated_at
BEFORE UPDATE ON note
FOR EACH ROW
EXECUTE PROCEDURE extensions.set_updated_at();

CREATE TRIGGER set_tag_updated_at
BEFORE UPDATE ON tag
FOR EACH ROW
EXECUTE PROCEDURE extensions.set_updated_at();

-- User Table RLS and Policies
ALTER TABLE public.app_user
ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users can view their own profile"
  ON public.app_user
  FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "users can update their own profile"
  ON public.app_user
  FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "users can insert their own profile"
  ON public.app_user
  FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "users can delete their own profile"
  ON public.app_user
  FOR DELETE
  USING (auth.uid() = id);

-- UserProfile Table RLS and Policies
ALTER TABLE public.user_profile
ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users can view their own profile"
  ON public.user_profile
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "users can update their own profile"
  ON public.user_profile
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "users can insert their own profile"
  ON public.user_profile
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);    

CREATE POLICY "users can delete their own profile"
  ON public.user_profile
  FOR DELETE
  USING (auth.uid() = user_id);

-- Note Table RLS and Policies
ALTER TABLE public.note
ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users can view their own notes"
  ON public.note
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "users can update their own notes"
  ON public.note
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "users can insert their own notes"
  ON public.note
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);    

CREATE POLICY "users can delete their own notes"
  ON public.note
  FOR DELETE
  USING (auth.uid() = user_id);

-- Tag Table RLS and Policies
ALTER TABLE public.tag
ENABLE ROW LEVEL SECURITY;      

CREATE POLICY "users can view their own tags"
  ON public.tag
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "users can update their own tags"
  ON public.tag
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "users can insert their own tags"
  ON public.tag
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users can delete their own tags"
  ON public.tag
  FOR DELETE
  USING (auth.uid() = user_id);

-- NoteTag Table RLS and Policies
ALTER TABLE public.note_tag
ENABLE ROW LEVEL SECURITY;          

CREATE POLICY "users can view their own note-tag associations"
  ON public.note_tag
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "users can update their own note-tag associations"
  ON public.note_tag
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "users can insert only their own note-tag associations"
  ON public.note_tag
  FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM note WHERE id = note_id AND user_id = auth.uid()
    )
    AND EXISTS (
      SELECT 1 FROM tag WHERE id = tag_id AND user_id = auth.uid()
    )
  );

CREATE POLICY "users can delete their own note-tag associations"
  ON public.note_tag
  FOR DELETE
  USING (auth.uid() = user_id);


-- Indexes for performance
CREATE INDEX idx_note_user_id ON note(user_id);
CREATE INDEX idx_tag_user_id ON tag(user_id);
CREATE INDEX idx_note_tag_user_id ON note_tag(user_id);
