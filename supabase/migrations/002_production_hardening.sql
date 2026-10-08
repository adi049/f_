-- Production hardening for LeadFlow Outreach CRM
ALTER TABLE public.leads
  ADD COLUMN IF NOT EXISTS call_attempts INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS last_call_outcome TEXT;

ALTER TABLE public.lead_message_progress
  ADD COLUMN IF NOT EXISTS state TEXT NOT NULL DEFAULT 'opened',
  ADD COLUMN IF NOT EXISTS opened_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ADD COLUMN IF NOT EXISTS confirmed_sent_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_leads_priority ON public.leads(priority);
CREATE INDEX IF NOT EXISTS idx_leads_last_contacted ON public.leads(last_contacted_at DESC);
CREATE INDEX IF NOT EXISTS idx_progress_state ON public.lead_message_progress(state);

ALTER TABLE public.lead_message_progress DROP CONSTRAINT IF EXISTS lead_message_progress_state_check;
ALTER TABLE public.lead_message_progress ADD CONSTRAINT lead_message_progress_state_check
  CHECK (state IN ('opened','confirmed_sent'));

CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$;

DROP TRIGGER IF EXISTS profiles_set_updated_at ON public.profiles;
CREATE TRIGGER profiles_set_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
DROP TRIGGER IF EXISTS folders_set_updated_at ON public.folders;
CREATE TRIGGER folders_set_updated_at BEFORE UPDATE ON public.folders FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
DROP TRIGGER IF EXISTS leads_set_updated_at ON public.leads;
CREATE TRIGGER leads_set_updated_at BEFORE UPDATE ON public.leads FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
DROP TRIGGER IF EXISTS notes_set_updated_at ON public.notes;
CREATE TRIGGER notes_set_updated_at BEFORE UPDATE ON public.notes FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
DROP TRIGGER IF EXISTS templates_set_updated_at ON public.message_templates;
CREATE TRIGGER templates_set_updated_at BEFORE UPDATE ON public.message_templates FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
DROP TRIGGER IF EXISTS api_configs_set_updated_at ON public.api_configs;
CREATE TRIGGER api_configs_set_updated_at BEFORE UPDATE ON public.api_configs FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE OR REPLACE FUNCTION public.sync_followup_completion()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.completed = TRUE AND (OLD.completed = FALSE OR OLD.completed_at IS NULL) THEN NEW.completed_at = NOW();
  ELSIF NEW.completed = FALSE THEN NEW.completed_at = NULL;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS followups_set_completed_at ON public.followups;
CREATE TRIGGER followups_set_completed_at BEFORE UPDATE ON public.followups FOR EACH ROW EXECUTE FUNCTION public.sync_followup_completion();