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
    miss_count  int default 1,      -- 이 문제를 틀린/모르겠음 표시한 누적 횟수 (재출현 우선순위에 사용)
    memo        text default '',    -- 사용자가 남긴 개인 메모
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
    miss_count  int default 1,
    memo        text default '',
    updated_at  timestamptz not null default now(),
    primary key (owner_key, wrong_id)
);

-- "안 푼 문제" — 다 풀지 못하고 중간에 제출해서 답을 고르지 않은 문제,
-- 또는 정답이었지만 '다시 풀기'로 수동 표시해둔 문제. wrong 테이블과
-- 컬럼 구조가 동일하다(같은 코드 경로를 공유하기 때문).
create table if not exists ffi_unanswered_mcq (
    owner_key   text not null,
    wrong_id    text not null,
    category    text,
    question    text,
    options     jsonb,
    answer      int,
    source      text,
    reference   text,
    miss_count  int default 1,
    memo        text default '',
    updated_at  timestamptz not null default now(),
    primary key (owner_key, wrong_id)
);

create table if not exists ffi_unanswered_practical (
    owner_key   text not null,
    wrong_id    text not null,
    category    text,
    question    text,
    answer      text,
    source      text,
    official    boolean default false,
    qtype       text,
    miss_count  int default 1,
    memo        text default '',
    updated_at  timestamptz not null default now(),
    primary key (owner_key, wrong_id)
);

create table if not exists ffi_records (
    record_id           text primary key,
    owner_key           text not null,
    mode                text,
    date                timestamptz not null default now(),
    score               int,
    correct             int,
    total               int,
    subjects            jsonb,
    category_breakdown  jsonb,   -- { "과목명": { "attempts": n, "correct": n } } — 과목별 취약점 통계용
    created_at          timestamptz not null default now()
);

create index if not exists ffi_wrong_mcq_owner_idx on ffi_wrong_mcq (owner_key);
create index if not exists ffi_wrong_practical_owner_idx on ffi_wrong_practical (owner_key);
create index if not exists ffi_unanswered_mcq_owner_idx on ffi_unanswered_mcq (owner_key);
create index if not exists ffi_unanswered_practical_owner_idx on ffi_unanswered_practical (owner_key);
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
alter table ffi_unanswered_mcq enable row level security;
alter table ffi_unanswered_practical enable row level security;
alter table ffi_records enable row level security;

create policy "anon full access" on ffi_wrong_mcq for all
    using (true) with check (true);
create policy "anon full access" on ffi_wrong_practical for all
    using (true) with check (true);
create policy "anon full access" on ffi_unanswered_mcq for all
    using (true) with check (true);
create policy "anon full access" on ffi_unanswered_practical for all
    using (true) with check (true);
create policy "anon full access" on ffi_records for all
    using (true) with check (true);
