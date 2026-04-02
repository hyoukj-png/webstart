# 웹 검수 에이전트 계획서 v1.1 개정 및 SKILL.md 구현 완료 보고서

> 대상 문서: [web-audit-agent-plan.md](./web-audit-agent-plan.md)
> 참조 문서: [web-audit-agent-plan-review-report.md](./web-audit-agent-plan-review-report.md) (검토 보고서)
> 작성일: 2026-04-02
> 개정 범위: v1.0 → v1.1 + SKILL.md 전체 구현

---

## 1. 개정 요약

검토 보고서에서 지적된 6개 문제점과 추가 분석에서 발견된 3개 보완 사항을 반영하여 v1.1로 개정 완료.

| 구분 | 반영 | 미반영 (SKILL.md 구현 단계에서 처리) |
|------|------|------|
| 검토 보고서 지적 | 6건 | 0건 |
| 추가 분석 보완 | 3건 | 0건 |

---

## 2. 수정 내역

### 2.1 신뢰도 분류 체계 도입 (섹션 0 — 글로벌 공통 규칙)

**문제:** 추정이 많이 들어가는 단계(Agent 7, 8)에 신뢰도, 근거, 불확실성 표기가 강제되지 않아 환각성 ERD/API 추정이 후속 설계로 전파될 위험.

**수정 내용:**
- `Confirmed / Likely / Hypothesis / Unknown` 4단계 신뢰도 분류 체계 추가
- 모든 보고서 공통 칼럼 규격 정의: 항목, 관찰 내용, 근거, 신뢰도, 상태, 후속 확인 필요

**수정 위치:** 섹션 0, `단일 원본` 규칙 직후

---

### 2.2 외부 사이트 분석 보안 및 운영 정책 추가 (섹션 0)

**문제:** 외부 URL, 타사 사이트 분석에 필요한 보안/법적 가드레일이 전혀 없어 로그인 우회, PII 노출, 과도한 스크래핑 등 운영 리스크 발생 가능.

**수정 내용:**
- 6개 항목의 보안 운영 정책 테이블 추가
- 공개 페이지 한정, PII 마스킹, 인증정보 저장 금지, robots.txt 준수, rate limit 준수, 데이터 사용 범위 제한

**수정 위치:** 섹션 0, 신뢰도 체계 직후

---

### 2.3 단계별 입출력 의존성 명시 (섹션 3 — 에이전트 상세 스킬셋)

**문제:** (검토 보고서에서 놓친 점) Step 1~4가 순차 실행이라고만 되어 있고, 각 단계가 이전 단계의 어떤 산출물을 구체적으로 참조하는지 정의되지 않음.

**수정 내용:**
- Agent 5 (`/audit-ux`): 의존성 없음 (첫 단계), `_audit/target.md` 입력 추가
- Agent 6 (`/audit-ia`): `_audit/ux-report.md` 참조 (네비게이션 구조), Step 1 완료 의존
- Agent 7 (`/audit-tech`): `_audit/ia-report.md` 참조 (분석 대상 페이지 목록), Step 2 완료 의존, 네트워크 데이터 PII 제거 주의사항 추가
- Agent 8 (`/audit-db`): `_audit/ia-report.md` + `_audit/tech-report.md` 동시 참조, Step 2+3 완료 의존

**수정 위치:** 섹션 3, 각 에이전트의 입력 항목

---

### 2.4 `/audit-db` 입력 게이트 강화 (섹션 3 + 섹션 4)

**문제:** `/audit-db`가 `/audit-tech`의 API 호출 증거 없이도 실행 가능하게 설계되어, 가장 불확실한 단계가 가장 약한 입력으로 돌아감.

**수정 내용:**
- Agent 8 상세에 입력 게이트 규칙 3개 추가:
  - API 증거 있으면 → 정상 분석
  - API 증거 없으면 → Hypothesis 한정 모드
  - 게이트 판정 결과를 보고서 상단에 명시
- `_audit/db-report.md` 산출물 구조에 "입력 게이트 판정" 섹션 추가
- Step 4 체크리스트에 게이트 점검 항목 추가

**수정 위치:** 섹션 3 Agent 8, 섹션 4 Step 4

---

### 2.5 입력 데이터 수집 가이드 — Step 0 추가 (섹션 4)

**문제:** (검토 보고서에서 놓친 점) 수동 수집조차 어떻게 하는지 정의되지 않음. 사용자가 첫 단계에서 무엇을 어떤 형식으로 준비해야 하는지 불명확.

**수정 내용:**
- Step 0 "분석 대상 등록" 단계 신설
- `_audit/target.md` 템플릿 정의 (사이트명, URL, 유형, 분석 목적, 권한 범위, 입력 데이터 체크리스트)
- `_audit/status.md` 초기화 포함
- 파이프라인 다이어그램에 Step 0 반영

**수정 위치:** 섹션 4, Step 1 이전

---

### 2.6 인계 계약 수정 — Step 5/6 분리 (섹션 4)

**문제:** `/audit`가 `_audit/report.md`를 만들지만 `/pm`은 `_agency/client-brief.md`를 찾아 파이프라인이 끊김. 두 시스템 사이에 파일 형식 변환이 없음.

**수정 내용:**
- 기존 Step 5를 2단계로 분리:
  - **Step 5:** 종합 보고서 생성 (`_audit/report.md`), Blocked/Hypothesis 항목은 `known gaps` 섹션 강제 포함
  - **Step 6:** 제작 팀 인계 — `_audit/report.md` → `_agency/client-brief.md` 자동 변환 생성
- 변환 규칙 명시: 사업명, 핵심 기능, 페이지 목록, 기술 요구사항 추출
- `/contract` 연결: `_audit/db-report.md`의 ERD 초안을 참고 입력으로 활용 가능 안내
- `/qa-check` 연결: `_audit/report.md`의 접근성/성능 문제를 검증 항목에 포함 권장
- 위치 다이어그램(섹션 1)에 인계 포인트 상세 반영

**수정 위치:** 섹션 1 다이어그램, 섹션 4 Step 5~6, 파이프라인 다이어그램

---

### 2.7 상태 관리 템플릿 정의 (섹션 5)

**문제:** `status.md`가 자동 관리된다고만 되어 있고 상태 모델이 없어 부분 실행, 재시도, 실패 복구 구현이 어려움.

**수정 내용:**
- `_audit/status.md` 템플릿 명시 (Step 0~6 전체 포함)
- 상태값 4종 정의: 대기, 진행중, 완료, 차단
- 기존 제작 파이프라인 `_agency/status.md` 형식과 호환되도록 칼럼 구조 통일

**수정 위치:** 섹션 5, 산출물 폴더 구조 직후

---

### 2.8 산출물 폴더 구조 업데이트 (섹션 5)

**문제:** `_agency/client-brief.md` 생성이 추가되었으나 폴더 구조에 반영되지 않음.

**수정 내용:**
- 폴더 구조에 `_agency/client-brief.md` 추가 (Step 6에서 자동 생성)
- `report.md` 설명에 "known gaps 포함" 명시
- `target.md` 설명에 "권한 범위" 추가

**수정 위치:** 섹션 5

---

### 2.9 구현 로드맵 및 메타데이터 정리 (섹션 9, 10)

**수정 내용:**
- 버전을 v1.0 → v1.1로 변경, 변경 이력 추가
- 구현 로드맵 1~2단계 설명에 신뢰도 체계, 보안 정책, 입력 게이트, 인계 변환 반영
- 검토 요청 사항 #2를 인계 방식 확정 질문으로 변경
- install.sh 설명을 5개 스킬 추가 기준으로 명확화

**수정 위치:** 문서 상단 메타데이터, 섹션 8, 섹션 9, 섹션 10

---

## 3. SKILL.md 구현 결과

### 3.1 구현 완료 파일 목록

로드맵 1~2단계를 순차 진행하여 5개 SKILL.md를 모두 구현 완료.

| 스킬 | 파일 | 라인 수 | 주요 구현 내용 |
|------|------|---------|--------------|
| `/audit` | `skills/audit/SKILL.md` | 230 | Step 0 대상 등록, Playwright 자동 수집, Step 5 종합 보고서(known gaps), Step 6 client-brief.md 변환, 보안 규칙 |
| `/audit-ux` | `skills/audit-ux/SKILL.md` | 201 | 컬러/폰트/컴포넌트 자동 추출(Playwright), 접근성 체크리스트, 신뢰도 체계 적용 |
| `/audit-ia` | `skills/audit-ia/SKILL.md` | 186 | 내부 링크 전체 수집, 사이트맵 재구성, 사용자 여정 평가, SEO 메타데이터 분석, rate limit 준수 |
| `/audit-tech` | `skills/audit-tech/SKILL.md` | 230 | 프레임워크 감지(React/Vue/Angular/jQuery/WordPress), CWV 측정, 서드파티 분석, 민감 헤더 자동 필터 |
| `/audit-db` | `skills/audit-db/SKILL.md` | 232 | 입력 게이트 판정(API 증거 유무), API 호출+폼 필드 자동 수집, ERD 역설계, PII 마스킹 |

### 3.2 결정 사항

구현 과정에서 아래 4개 검토 요청 사항을 결정:

| # | 질문 | 결정 | 근거 |
|---|------|------|------|
| 1 | 커맨드명 확정 | `/audit`, `/audit-ux`, `/audit-ia`, `/audit-tech`, `/audit-db` 확정 | 사용자 승인 |
| 2 | 인계 방식 | A) `/audit`가 `client-brief.md` 자동 생성 | 기존 `/pm` 스킬 수정 불필요, 제작 파이프라인 영향 없음 |
| 3 | 브라우저 자동화 | 포함 (Playwright) | 각 SKILL.md에 Playwright 스크립트 내장, 실패 시 수동 입력 폴백 |
| 4 | 구현 순서 | 순차 (1단계 → 2단계) | `/audit-db`가 `/audit-tech` 산출물에 의존하므로 앞단 확인 후 구현 |

### 3.3 공통 설계 패턴

5개 SKILL.md 모두 기존 제작 파이프라인 스킬(pm, design 등)의 패턴을 따름:

- **Frontmatter**: name, description, allowed-tools (Bash 추가 — Playwright 실행용)
- **게이트 체크**: `_audit/status.md` 읽어 선행 단계 완료 확인 → 미충족 시 중단 + 안내
- **산출물 저장**: 지정된 `_audit/*.md` 파일에 덮어쓰기
- **상태 업데이트**: `_audit/status.md` 해당 행을 ✅ 완료로 갱신
- **완료 메시지**: 저장 위치 + 다음 단계 안내

추가된 패턴:
- **Playwright 자동 수집**: URL이 있으면 자동 실행, 실패 시 수동 입력 폴백
- **보안 필터**: 쿠키/토큰/인증 헤더 자동 제거, PII(이메일/전화번호) 마스킹
- **신뢰도 체계**: 모든 분석 표에 근거, 신뢰도(High/Medium/Low), 상태(Confirmed/Likely/Hypothesis/Unknown) 칼럼 포함
- **입력 게이트**: `/audit-db`에서 API 증거 유무에 따라 산출물 신뢰 등급 자동 분류

### 3.4 install.sh 업데이트 내용

- 안내 메시지에 [검수 파이프라인] 섹션 추가 (5개 스킬)
- 다음 단계 안내에 `/audit https://example.com` 추가

---

## 4. 수정하지 않은 항목과 이유

| 항목 | 이유 |
|------|------|
| `/pm` 스킬 수정 | 인계 방식을 `/audit`가 `client-brief.md`를 생성하는 방향으로 결정했으므로 수정 불필요 |
| PDF 보고서 생성 | 3단계 선택 사항. 파이프라인 동작에 필수 아님 |
| Playwright 설치 자동화 | 사용자 환경마다 다르므로 스킬 내부에서 실패 시 안내하는 방식으로 처리 |

---

## 5. 검토 보고서 대비 추가 반영 사항

검토 보고서에서 놓친 점 3가지를 추가로 반영:

| # | 항목 | 반영 위치 |
|---|------|----------|
| 1 | 입력 데이터 수집 방법 미정의 → Step 0 + target.md 템플릿 + Playwright 자동 수집 | 계획서 섹션 4, `skills/audit/SKILL.md` |
| 2 | 단계별 산출물 참조 관계 미정의 → 각 에이전트에 의존성 명시 | 계획서 섹션 3, 각 SKILL.md 게이트 체크 |
| 3 | `/contract`, `/qa-check`와의 연결 경로 부재 → Step 6에 선택적 연결 안내 | 계획서 섹션 4, `skills/audit/SKILL.md` Step 7 |

---

## 6. 최종 파일 변경 목록

| 파일 | 상태 | 설명 |
|------|------|------|
| `web-audit-agent-plan.md` | 수정 | v1.0 → v1.1 개정 (9개 항목 반영) |
| `skills/audit/SKILL.md` | 신규 | 오케스트레이터 (Step 0 + 5 + 6) |
| `skills/audit-ux/SKILL.md` | 신규 | UI/UX 리서처 |
| `skills/audit-ia/SKILL.md` | 신규 | 정보 아키텍트 |
| `skills/audit-tech/SKILL.md` | 신규 | 기술 스택 진단 |
| `skills/audit-db/SKILL.md` | 신규 | 데이터베이스 유추 |
| `install.sh` | 수정 | 검수 파이프라인 5개 스킬 안내 추가 |
| `web-audit-agent-plan-revision-report.md` | 수정 | 본 보고서 (구현 결과 추가) |

---

## 7. 다음 단계

| # | 작업 | 설명 |
|---|------|------|
| 1 | **install.sh 실행** | `bash install.sh`로 13개 스킬 전체 설치 |
| 2 | **Playwright 설치 확인** | `npx playwright install chromium` |
| 3 | **통합 테스트** | 실제 사이트 대상 `/audit --full https://example.com` 실행 |
| 4 | **피드백 반영** | 테스트 결과에 따라 SKILL.md 조정 |
| 5 | **(선택) PDF 보고서** | 클라이언트 전달용 포맷 필요 시 추가 구현 |
