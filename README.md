# LeadFlow Outreach CRM

Production-oriented lead outreach CRM for cold calling and manual WhatsApp outreach.

## Stack
- Next.js App Router + React
- Tailwind CSS
- Drizzle ORM
- Supabase PostgreSQL
- SheetJS + PapaParse
- Supabase Edge Function for external lead API proxying

## Main workflow
Import Excel/CSV or fetch leads -> organize into folders -> call/WhatsApp -> record outreach -> add notes -> schedule follow-ups -> resolve reminders -> convert/close.

## Important
- No automatic/bulk WhatsApp sending.
- WhatsApp actions open a prefilled wa.me message; the user manually presses Send.
- No fake dashboard metrics or fake lead records.
- Secrets stay server-side.
- Apply the SQL migration in `supabase/migrations/001_lead_crm.sql` to the intended Supabase project.
- Configure `.env.local` from `.env.example`.

## Commands
```bash
npm install
npm run dev
npm run build
npm run typecheck
```
