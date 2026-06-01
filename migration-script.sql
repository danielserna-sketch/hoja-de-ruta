-- ════════════════════════════════════════════════════════════
-- SUPABASE SCHEMA: Plans & Initiatives
-- ════════════════════════════════════════════════════════════

-- 1. Create plans table
create table if not exists public.plans (
  id text primary key,
  name text not null,
  owner text,
  description text,
  created_at date,
  updated_at timestamp default now()
);

-- 2. Create initiatives table
create table if not exists public.initiatives (
  id text primary key,
  plan_id text not null references public.plans(id) on delete cascade,
  name text not null,
  responsible text,
  start_date date,
  end_date date,
  priority text default 'medium',
  status text default 'not-started',
  progress integer default 0,
  phases text[],
  updated_at timestamp default now()
);

-- 3. Disable RLS (para usar con anon key públicamente)
-- Si usas Auth después, comenta esto y configura policies
alter table public.plans disable row level security;
alter table public.initiatives disable row level security;

-- 4. Create indexes
create index if not exists idx_initiatives_plan_id on public.initiatives(plan_id);
