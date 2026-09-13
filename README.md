# 화재조사관 자격시험 문제풀이

1차 필기(객관식) · 2차 실기(단답형/주관식) 자가학습 퀴즈 앱. 정적 HTML 한 장으로 동작하며, Supabase를 통해 "틀린문제 모음"과 성장 기록을 기기 간(회사 컴퓨터 ↔ 휴대폰) 자동 동기화합니다.

## 배포 (Vercel)

1. 이 저장소를 Vercel에 Import (Framework Preset: **Other**, 빌드 명령 없음 — 정적 파일 그대로 서빙)
2. 배포 후 발급되는 `https://xxx.vercel.app` 주소를 북마크하거나 휴대폰 홈 화면에 추가해서 사용

## Supabase 설정

`index.html` 상단의 `SUPABASE_URL`, `SUPABASE_ANON_KEY` 값을 실제 프로젝트 값으로 채워야 동기화가 활성화됩니다. 테이블 스키마는 `schema.sql` 참고(Supabase SQL Editor에서 실행).

## 동기화 방식

앱 첫 화면에서 "소방서"와 "이름"을 입력하면, 그 조합을 키로 Supabase에 오답 목록과 응시 기록이 저장/조회됩니다. 입력하지 않으면 이 브라우저에만 로컬 저장됩니다.
