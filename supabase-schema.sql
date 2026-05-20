-- ============================================================
-- HEAD MKT APP — Supabase Schema
-- Cole este SQL no Supabase > SQL Editor > New Query > Run
-- ============================================================

-- PROFILES (extends auth.users)
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  email text,
  name text,
  avatar_url text,
  role text default 'user',
  subscription_status text default 'free',
  subscription_plan text,
  stripe_customer_id text,
  stripe_subscription_id text,
  theme text default 'light',
  created_at timestamptz default now()
);
alter table public.profiles enable row level security;
create policy "Users can view own profile" on public.profiles for select using (auth.uid() = id);
create policy "Users can update own profile" on public.profiles for update using (auth.uid() = id);
create policy "Admin full access profiles" on public.profiles for all using (
  exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
);

-- Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, name, role, subscription_status)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'name', split_part(new.email,'@',1)),
    case when new.email = 'dudasants8@gmail.com' then 'admin' else 'user' end,
    case when new.email = 'dudasants8@gmail.com' then 'active' else 'free' end
  );
  return new;
end;
$$ language plpgsql security definer;
create or replace trigger on_auth_user_created
  after insert on auth.users for each row execute procedure public.handle_new_user();

-- LEADS
create table if not exists public.leads (
  id bigint generated always as identity primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  nome text,
  wpp text,
  origem text default 'Instagram',
  temp text default 'Morno',
  status text default 'Novo',
  data date,
  interesse text,
  acao text,
  notas text,
  created_at timestamptz default now()
);
alter table public.leads enable row level security;
create policy "Users manage own leads" on public.leads for all using (auth.uid() = user_id);

-- PIPELINE
create table if not exists public.pipeline (
  id bigint generated always as identity primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  titulo text,
  formato text,
  plataforma text,
  etapa text default 'Ideia',
  prazo date,
  resp text,
  created_at timestamptz default now()
);
alter table public.pipeline enable row level security;
create policy "Users manage own pipeline" on public.pipeline for all using (auth.uid() = user_id);

-- CALENDAR
create table if not exists public.calendar_items (
  id bigint generated always as identity primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  titulo text,
  plat text,
  fmt text,
  data date,
  status text default 'Planejado',
  notify_at timestamptz,
  created_at timestamptz default now()
);
alter table public.calendar_items enable row level security;
create policy "Users manage own calendar" on public.calendar_items for all using (auth.uid() = user_id);

-- METRICS
create table if not exists public.metrics (
  id bigint generated always as identity primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  periodo text,
  ig_head integer default 0,
  ig_pes integer default 0,
  li integer default 0,
  tt integer default 0,
  yt integer default 0,
  alcance integer default 0,
  created_at timestamptz default now()
);
alter table public.metrics enable row level security;
create policy "Users manage own metrics" on public.metrics for all using (auth.uid() = user_id);

-- CAREER PROJECTS
create table if not exists public.career_projects (
  id bigint generated always as identity primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  nome text,
  cat text,
  status text default 'Não iniciado',
  receita text,
  prazo text,
  acao text,
  created_at timestamptz default now()
);
alter table public.career_projects enable row level security;
create policy "Users manage own career" on public.career_projects for all using (auth.uid() = user_id);

-- TASKS
create table if not exists public.tasks (
  id bigint generated always as identity primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  titulo text,
  prio text default 'Média',
  area text default 'HEAD IMOB',
  prazo date,
  done boolean default false,
  notify_at timestamptz,
  created_at timestamptz default now()
);
alter table public.tasks enable row level security;
create policy "Users manage own tasks" on public.tasks for all using (auth.uid() = user_id);

-- NOTES
create table if not exists public.notes (
  id bigint generated always as identity primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  title text default 'Sem título',
  content text default '',
  color text default '#ffffff',
  pinned boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
alter table public.notes enable row level security;
create policy "Users manage own notes" on public.notes for all using (auth.uid() = user_id);

-- PUSH SUBSCRIPTIONS
create table if not exists public.push_subscriptions (
  id bigint generated always as identity primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  subscription jsonb,
  created_at timestamptz default now()
);
alter table public.push_subscriptions enable row level security;
create policy "Users manage own push subs" on public.push_subscriptions for all using (auth.uid() = user_id);

-- Storage bucket for avatars
insert into storage.buckets (id, name, public) values ('avatars', 'avatars', true) on conflict do nothing;
create policy "Avatar upload" on storage.objects for insert with check (bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]);
create policy "Avatar view" on storage.objects for select using (bucket_id = 'avatars');
create policy "Avatar update" on storage.objects for update using (bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]);
create policy "Avatar delete" on storage.objects for delete using (bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]);

-- Indexes
create index if not exists leads_user_id_idx on public.leads(user_id);
create index if not exists pipeline_user_id_idx on public.pipeline(user_id);
create index if not exists calendar_items_user_id_idx on public.calendar_items(user_id);
create index if not exists tasks_user_id_idx on public.tasks(user_id);
create index if not exists notes_user_id_idx on public.notes(user_id);
