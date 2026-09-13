-- 화재조사관 문제풀이 앱 — 2026-09 기능 추가용 마이그레이션
-- (과목별 취약점 통계 / 오답 재출현 우선순위 / 오답 메모 / 안 푼 문제 모음)
--
-- 이미 schema.sql을 실행해서 테이블이 만들어져 있는 Supabase 프로젝트에
-- 필요한 컬럼과 테이블을 추가합니다. Supabase 대시보드 → SQL Editor에
-- 붙여넣고 실행(Run)해 주세요. 이미 있는 컬럼/테이블은 건드리지 않으므로
-- 여러 번 실행해도 안전합니다 (IF NOT EXISTS).

alter table ffi_wrong_mcq
    add column if not exists miss_count int default 1,
    add column if not exists memo text default '';

alter table ffi_wrong_practical
    add column if not exists miss_count int default 1,
    add column if not exists memo text default '';

alter table ffi_records
    add column if not exists category_breakdown jsonb;

-- "안 푼 문제" 모음을 위한 새 테이블 (다 풀지 못하고 중간에 제출해서 답을
-- 고르지 않은 문제, 또는 정답이었지만 '다시 풀기'로 표시해둔 문제)
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

create index if not exists ffi_unanswered_mcq_owner_idx on ffi_unanswered_mcq (owner_key);
create index if not exists ffi_unanswered_practical_owner_idx on ffi_unanswered_practical (owner_key);

alter table ffi_unanswered_mcq enable row level security;
alter table ffi_unanswered_practical enable row level security;

do $$
begin
    if not exists (select 1 from pg_policies where tablename = 'ffi_unanswered_mcq' and policyname = 'anon full access') then
        create policy "anon full access" on ffi_unanswered_mcq for all using (true) with check (true);
    end if;
    if not exists (select 1 from pg_policies where tablename = 'ffi_unanswered_practical' and policyname = 'anon full access') then
        create policy "anon full access" on ffi_unanswered_practical for all using (true) with check (true);
    end if;
end $$;
