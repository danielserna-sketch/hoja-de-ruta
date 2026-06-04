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
  workspace_scope text not null default 'default',
  owner_user_id uuid,
  updated_at timestamp default now()
);

-- 2. Create initiatives table
create table if not exists public.initiatives (
  id text primary key,
  plan_id text not null references public.plans(id) on delete cascade,
  name text not null,
  responsible text,
  responsible_stratika text,
  start_date date,
  end_date date,
  priority text default 'medium',
  status text default 'not-started',
  progress integer default 0,
  phases text[],
  tasks jsonb default '[]'::jsonb,
  workspace_scope text not null default 'default',
  owner_user_id uuid,
  updated_at timestamp default now()
);

-- 2.1 Ensure columns exist for existing projects created with earlier schema
alter table public.initiatives add column if not exists responsible_stratika text;
alter table public.initiatives add column if not exists tasks jsonb default '[]'::jsonb;
alter table public.plans add column if not exists workspace_scope text not null default 'default';
alter table public.initiatives add column if not exists workspace_scope text not null default 'default';
alter table public.plans add column if not exists owner_user_id uuid;
alter table public.initiatives add column if not exists owner_user_id uuid;

alter table public.plans alter column owner_user_id set default auth.uid();
alter table public.initiatives alter column owner_user_id set default auth.uid();

update public.plans
set owner_user_id = coalesce(owner_user_id, auth.uid(), '00000000-0000-0000-0000-000000000000'::uuid)
where owner_user_id is null;

update public.initiatives i
set owner_user_id = coalesce(i.owner_user_id, p.owner_user_id)
from public.plans p
where i.plan_id = p.id
  and i.owner_user_id is null;

update public.initiatives
set owner_user_id = coalesce(owner_user_id, auth.uid(), '00000000-0000-0000-0000-000000000000'::uuid)
where owner_user_id is null;

alter table public.plans alter column owner_user_id set not null;
alter table public.initiatives alter column owner_user_id set not null;

-- 3. Enable RLS and create per-user policies.
alter table public.plans enable row level security;
alter table public.initiatives enable row level security;

drop policy if exists plans_select_own on public.plans;
drop policy if exists plans_insert_own on public.plans;
drop policy if exists plans_update_own on public.plans;
drop policy if exists plans_delete_own on public.plans;

create policy plans_select_own on public.plans
  for select to authenticated
  using (owner_user_id = auth.uid());

create policy plans_insert_own on public.plans
  for insert to authenticated
  with check (owner_user_id = auth.uid());

create policy plans_update_own on public.plans
  for update to authenticated
  using (owner_user_id = auth.uid())
  with check (owner_user_id = auth.uid());

create policy plans_delete_own on public.plans
  for delete to authenticated
  using (owner_user_id = auth.uid());

drop policy if exists initiatives_select_own on public.initiatives;
drop policy if exists initiatives_insert_own on public.initiatives;
drop policy if exists initiatives_update_own on public.initiatives;
drop policy if exists initiatives_delete_own on public.initiatives;

create policy initiatives_select_own on public.initiatives
  for select to authenticated
  using (owner_user_id = auth.uid());

create policy initiatives_insert_own on public.initiatives
  for insert to authenticated
  with check (owner_user_id = auth.uid());

create policy initiatives_update_own on public.initiatives
  for update to authenticated
  using (owner_user_id = auth.uid())
  with check (owner_user_id = auth.uid());

create policy initiatives_delete_own on public.initiatives
  for delete to authenticated
  using (owner_user_id = auth.uid());

-- 4. Create indexes
create index if not exists idx_initiatives_plan_id on public.initiatives(plan_id);
create index if not exists idx_plans_workspace_scope on public.plans(workspace_scope);
create index if not exists idx_initiatives_workspace_scope on public.initiatives(workspace_scope);
create index if not exists idx_initiatives_scope_plan on public.initiatives(workspace_scope, plan_id);
create index if not exists idx_plans_owner_user_id on public.plans(owner_user_id);
create index if not exists idx_initiatives_owner_user_id on public.initiatives(owner_user_id);
