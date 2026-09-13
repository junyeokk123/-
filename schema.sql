-- 화재조사관 문제풀이 앱 — Supabase 스키마
-- Supabase 대시보드의 SQL Editor에 붙여넣고 실행하세요.
-- (커넥터로 직접 실행한 경우 이 파일은 참고/백업용입니다.)

create table if not exists ffi_wrong_mcq (
    owner_key   text not null,
    wrong_id    text not null,
    category    text,
    question    text,
    options     jsonb,
    answer      int,
    source      text,
    reference   text,
    updated_at  timestamptz not null default now(),
    primary key (owner_key, wrong_id)
);

create table if not exists ffi_wrong_practical (
    owner_key   text not null,
    wrong_id    text not null,
    category    text,
    question    text,
    answer      text,
    source      text,
    official    boolean default false,
    qtype       text,
    updated_at  timestamptz not null default now(),
    primary key (owner_key, wrong_id)
);

create table if not exists ffi_records (
    record_id   text primary key,
    owner_key   text not null,
    mode        text,
    date        timestamptz not null default now(),
    score       int,
    correct     int,
    total       int,
    subjects    jsonb,
    created_at  timestamptz not null default now()
);

create index if not exists ffi_wrong_mcq_owner_idx on ffi_wrong_mcq (owner_key);
create index if not exists ffi_wrong_practical_owner_idx on ffi_wrong_practical (owner_key);
create index if not exists ffi_records_owner_idx on ffi_records (owner_key);

-- RLS: this is a small personal/team study tool with no real authentication
-- (people identify themselves by typing 소방서+이름), so rows are scoped by
-- owner_key at the application layer rather than by a Postgres auth.uid().
-- We enable RLS and allow the anon key full access — anyone who has the
-- project's URL + anon key (i.e. anyone who can view the deployed site's
-- page source) could in principle read/write any owner_key's rows. There's
-- no sensitive data here (quiz scores and a chosen name), so this tradeoff
-- is acceptable for this use case. Tighten later with Supabase Auth if the
-- app ever needs real per-person login.
alter table ffi_wrong_mcq enable row level security;
alter table ffi_wrong_practical enable row level security;
alter table ffi_records enable row level security;

create policy "anon full access" on ffi_wrong_mcq for all
    using (true) with check (true);
create policy "anon full access" on ffi_wrong_practical for all
    using (true) with check (true);
create policy "anon full access" on ffi_records for all
    using (true) with check (true);
