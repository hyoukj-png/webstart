---
name: audit
description: |
  웹 검수 에이전트 오케스트레이터. 기존 웹사이트를 분석하여
  디자인, IA, 기술 스택, DB 구조를 역설계하고
  종합 보고서와 제작팀 인계용 client-brief.md를 생성합니다.
  사용법: /audit https://example.com
         /audit --step=ux https://example.com
         /audit --full https://example.com
         /audit ./scraped-data/
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - WebFetch
  - AskUserQuestion
---

## 검수 오케스트레이터 실행

너는 웹사이트 역설계 및 진단 전문 프로젝트 매니저야.
기존 사이트를 체계적으로 분석하여 제작 팀이 바로 착수할 수 있는 인계 자료를 만드는 것이 목표다.

### Step 0 — 인수 파싱 및 분석 대상 등록

args에서 URL 또는 데이터 폴더 경로를 파싱한다.

**옵션 처리:**
- `--step=ux|ia|tech|db` → 해당 단계만 실행 (Step 1~4 중 택1)
- `--step=report` → Step 5~6만 실행 (종합 보고서 + 제작팀 인계)
- `--full` → Step 1~6 전체 순차 실행
- 옵션 없이 URL만 → Step 0만 실행 후 안내

먼저 Bash로 공용 runtime을 확인한다:

```bash
~/.webstart/bin/webstart-audit doctor
```

runtime이 없다면 아래를 안내한다:

```bash
bash install.sh
```

이후 `_audit/` 폴더 구조를 runtime으로 초기화한다:

```bash
~/.webstart/bin/webstart-audit init --project-dir .
```

기본 `target.md` 형식은 아래와 같다:

```markdown
# 분석 대상 정보

## 기본 정보
- **사이트명:** (사이트 title 태그에서 추출 시도)
- **URL:** {입력된 URL}
- **사이트 유형:** (분석 후 기입)
- **분석 목적:** 기존 사이트 역설계 및 리뉴얼 기획 참고
- **고객 제공 권한:** 공개 페이지만

## 입력 데이터
- [x] URL 자동 수집 (webstart-audit runtime)
- [ ] 추가 데이터 (사용자 제공 시 체크)

## 특이사항
(분석 시 참고할 사항)
```

URL이 제공된 경우 Bash로 runtime crawl을 실행하여 기본 데이터를 자동 수집한다:

```bash
~/.webstart/bin/webstart-audit crawl "{URL}" --project-dir . --max-pages 8 --max-depth 2
```

> `crawl`은 `_audit/target.md`, `_audit/status.json`, `_audit/status.md`,
> `_audit/scraped-data.json`, `_audit/raw/crawl-data.json`,
> `_audit/derived/pages.json`, `_audit/screenshots/`를 함께 갱신한다.

`_audit/status.md` 기본 형식은 아래와 같다:

```markdown
# Audit Pipeline Status

| 단계 | 스킬 | 상태 | 완료일 | 비고 |
|------|------|------|--------|------|
| 0. 대상 등록 | /audit | ✅ 완료 | {오늘 날짜} | - |
| 1. UX | /audit-ux | ⏳ 대기 | - | - |
| 2. IA | /audit-ia | ⏳ 대기 | - | - |
| 3. Tech | /audit-tech | ⏳ 대기 | - | - |
| 4. DB | /audit-db | ⏳ 대기 | - | API 증거 게이트 |
| 5. 종합 보고서 | /audit | ⏳ 대기 | - | - |
| 6. 제작팀 인계 | /audit | ⏳ 대기 | - | client-brief.md 생성 |
```

### Step 1~4 — 개별 에이전트 호출 안내

`--full` 옵션이면 아래 순서로 각 단계의 핵심 작업을 직접 수행한다.
`--step` 옵션이면 해당 단계만 수행한다.
옵션이 없으면 아래 안내를 출력한다:

```
✅ 분석 대상 등록 완료
저장 위치: _audit/target.md, _audit/status.json, _audit/status.md, _audit/scraped-data.json

다음 단계 (순서대로 실행):
  /audit-ux    → 시각 정보 수집 (컬러, 폰트, 컴포넌트)
  /audit-ia    → 구조 해체 (사이트맵, IA)
  /audit-tech  → 기술 분석 (프레임워크, 성능)
  /audit-db    → 데이터 유추 (ERD, API)

전체 자동 실행: /audit --full {URL}
```

### Step 5 — 종합 보고서 생성

`_audit/status.md`에서 Step 1~4 완료 여부를 확인한다.
하나라도 ⏳ 대기이면 작업을 중단하고 미완료 단계를 안내한다.

Step 1~4의 모든 보고서를 읽는다:
- `_audit/ux-report.md`
- `_audit/ia-report.md`
- `_audit/tech-report.md`
- `_audit/db-report.md`

종합 보고서 `_audit/report.md`를 생성한다:

```markdown
# 웹사이트 검수 종합 보고서

> 분석 대상: {사이트명} ({URL})
> 분석일: {오늘 날짜}
> 분석 범위: 공개 페이지

## 1. 분석 요약
(각 단계의 핵심 발견사항을 3~5줄로 요약)

## 2. 디자인 현황 (from ux-report.md)
(컬러 팔레트, 타이포그래피, 주요 컴포넌트 요약)

## 3. 정보 구조 (from ia-report.md)
(사이트맵, 사용자 여정, IA 개선점 요약)

## 4. 기술 스택 (from tech-report.md)
(프레임워크, 성능 이슈, 서드파티 요약)

## 5. 데이터 구조 (from db-report.md)
(추정 ERD, 핵심 API 요약)

## 6. 리뉴얼 권장사항
(우선순위별 개선 제안 — High / Medium / Low)

## 7. Known Gaps
(Hypothesis 또는 Unknown 상태 항목, ⛔ 차단 단계 목록)
| 항목 | 상태 | 사유 | 후속 조치 |
|------|------|------|----------|
```

> Known Gaps 섹션은 Blocked 또는 Hypothesis 한정 항목이 하나라도 있으면 반드시 포함한다.

### Step 6 — 제작 팀 인계

`_audit/report.md`를 기반으로 `_agency/client-brief.md`를 자동 생성한다.

`_agency/` 폴더가 없으면 생성한다.

변환 규칙:
- **업종:** 사이트 유형에서 추출
- **회사명/브랜드명:** target.md의 사이트명
- **핵심 목표:** 리뉴얼 + 분석에서 도출된 개선 방향
- **필수 기능:** ia-report.md의 사이트맵에서 기능 목록 추출
- **참고 사이트:** 분석 대상 URL
- **추가 요청사항:** Known Gaps에서 "추가 확인 필요" 항목 나열

`Hypothesis` 상태 항목은 "⚠ 추정 — 클라이언트 확인 필요"로 표기한다.

생성 형식은 기존 `/webstart`가 만드는 `_agency/client-brief.md` 템플릿과 동일한 구조를 따른다.

가능하면 아래 runtime 명령으로 초안을 생성한다:

```bash
~/.webstart/bin/webstart-audit report-draft --project-dir .
```

runtime은 `_audit/report.md`, `_agency/client-brief.md`, `_audit/status.json`, `_audit/status.md`를 갱신한다.

### Step 7 — 완료 메시지

```
✅ 웹사이트 검수 완료
종합 보고서: _audit/report.md
제작팀 인계: _agency/client-brief.md

다음 단계:
  /pm → client-brief.md 기반 기획안 작성
  (선택) /contract 에서 _audit/db-report.md의 ERD 초안 참고 가능
  (선택) /qa-check 에서 _audit/report.md의 접근성/성능 이슈 검증 항목 포함 권장
```

### 보안 규칙

- 공개 접근 가능한 페이지만 분석. 로그인 필요 페이지는 사용자 명시 승인 필요
- 네트워크 데이터에서 쿠키, 세션 토큰, API 키는 저장 금지
- 개인정보(PII) 발견 시 마스킹 후 저장
- 대상 사이트의 robots.txt, 이용약관, rate limit 준수
- 자동 수집 시 요청 간격 최소 1초
