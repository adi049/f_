-- ============================================================================
-- LEAD OUTREACH CRM - SUPABASE SQL SCHEMA & MIGRATIONS
-- Production PostgreSQL with Row Level Security (RLS), Indexes, and Triggers
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Application IDs are strings (some are prefixed), while auth user IDs are
-- stored as text so the existing server code and Supabase RLS stay compatible.

CREATE TABLE IF NOT EXISTS public.profiles (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::text,
  user_id TEXT NOT NULL,
  name TEXT NOT NULL DEFAULT 'Outreach Agent',
  email TEXT NOT NULL,
  country_code TEXT NOT NULL DEFAULT '+91',
  whatsapp_web_direct BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT uq_profiles_user UNIQUE (user_id)
);

CREATE TABLE IF NOT EXISTS public.folders (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::text,
  user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  icon TEXT NOT NULL DEFAULT 'briefcase',
  color TEXT NOT NULL DEFAULT '#3b82f6',
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.leads (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::text,
  user_id TEXT NOT NULL,
  folder_id TEXT REFERENCES public.folders(id) ON DELETE SET NULL,
  client_name TEXT,
  business_name TEXT NOT NULL,
  category TEXT,
  phone TEXT,
  whatsapp TEXT,
  email TEXT,
  website TEXT,
  instagram TEXT,
  address TEXT,
  city TEXT,
  state TEXT,
  country TEXT,
  source TEXT DEFAULT 'Excel/CSV Import',
  status TEXT NOT NULL DEFAULT 'New',
  priority TEXT NOT NULL DEFAULT 'Medium',
  notes TEXT,
  last_contacted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.lead_activities (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::text,
  lead_id TEXT NOT NULL REFERENCES public.leads(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL,
  type TEXT NOT NULL,
  title TEXT,
  description TEXT NOT NULL,
  metadata JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.followups (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::text,
  lead_id TEXT NOT NULL REFERENCES public.leads(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  scheduled_at TIMESTAMPTZ NOT NULL,
  completed BOOLEAN NOT NULL DEFAULT false,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.message_templates (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::text,
  user_id TEXT NOT NULL,
  folder_id TEXT REFERENCES public.folders(id) ON DELETE CASCADE,
  phase_number INTEGER NOT NULL DEFAULT 1,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.lead_message_progress (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::text,
  lead_id TEXT NOT NULL REFERENCES public.leads(id) ON DELETE CASCADE,
  template_id TEXT REFERENCES public.message_templates(id) ON DELETE SET NULL,
  phase_number INTEGER NOT NULL,
  sent_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.notes (
  id TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::text,
  lead_id TEXT NOT NULL REFERENCES public.leads(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.api_configs (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  endpoint_url TEXT NOT NULL,
  auth_header_name TEXT DEFAULT 'Authorization',
  auth_token TEXT,
  field_mappings JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_leads_user ON public.leads(user_id);
CREATE INDEX IF NOT EXISTS idx_leads_folder ON public.leads(folder_id);
CREATE INDEX IF NOT EXISTS idx_leads_status ON public.leads(status);
CREATE INDEX IF NOT EXISTS idx_leads_phone ON public.leads(phone);
CREATE INDEX IF NOT EXISTS idx_leads_whatsapp ON public.leads(whatsapp);
CREATE INDEX IF NOT EXISTS idx_leads_email ON public.leads(email);
CREATE INDEX IF NOT EXISTS idx_leads_created ON public.leads(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_followups_lead ON public.followups(lead_id);
CREATE INDEX IF NOT EXISTS idx_followups_user ON public.followups(user_id);
CREATE INDEX IF NOT EXISTS idx_followups_sched ON public.followups(scheduled_at);
CREATE INDEX IF NOT EXISTS idx_followups_completed ON public.followups(completed);

CREATE INDEX IF NOT EXISTS idx_activities_lead ON public.lead_activities(lead_id);
CREATE INDEX IF NOT EXISTS idx_activities_user ON public.lead_activities(user_id);
CREATE INDEX IF NOT EXISTS idx_activities_created ON public.lead_activities(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_templates_folder ON public.message_templates(folder_id);
CREATE INDEX IF NOT EXISTS idx_progress_lead ON public.lead_message_progress(lead_id);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.folders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lead_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.followups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.message_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lead_message_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.api_configs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own profile" ON public.profiles
  FOR ALL USING (auth.uid()::text = user_id) WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Users can manage own folders" ON public.folders
  FOR ALL USING (auth.uid()::text = user_id) WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Users can manage own leads" ON public.leads
  FOR ALL USING (auth.uid()::text = user_id) WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Users can manage own activities" ON public.lead_activities
  FOR ALL USING (auth.uid()::text = user_id) WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Users can manage own followups" ON public.followups
  FOR ALL USING (auth.uid()::text = user_id) WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Users can manage own templates" ON public.message_templates
  FOR ALL USING (auth.uid()::text = user_id) WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Users can view progress of own leads" ON public.lead_message_progress
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.leads
      WHERE leads.id = lead_message_progress.lead_id
        AND leads.user_id = auth.uid()::text
    )
  );

CREATE POLICY "Users can manage own notes" ON public.notes
  FOR ALL USING (auth.uid()::text = user_id) WITH CHECK (auth.uid()::text = user_id);

CREATE POLICY "Users can manage own API configs" ON public.api_configs
  FOR ALL USING (auth.uid()::text = user_id) WITH CHECK (auth.uid()::text = user_id);
