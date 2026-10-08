# LeadFlow Outreach CRM

Production-oriented lead outreach CRM for cold calling and manual WhatsApp outreach.

## Stack
- Next.js App Router + React + Supabase Auth
- Tailwind CSS
- Supabase PostgreSQL + RLS
- SheetJS + PapaParse
- Supabase Edge Function for external lead API proxying
- Browser-side Supabase data layer with email/password Auth

## Main workflow
Import Excel/CSV or fetch leads -> organize into folders -> call/WhatsApp -> record outreach -> add notes -> schedule follow-ups -> resolve reminders -> convert/close.

## Important
- No automatic/bulk WhatsApp sending.
- WhatsApp actions open a prefilled wa.me message; the user manually presses Send.
- No fake dashboard metrics or fake lead records.
- Secrets stay server-side.
- The production Supabase project is wired for this app; migrations live in `supabase/migrations/`. Set `.env.local` from `.env.example`.
- 

## Commands
```bash
npm install
npm run dev
npm run build
npm run typecheck
```
