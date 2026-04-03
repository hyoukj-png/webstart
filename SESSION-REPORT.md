# 작업 세션 보고서

> 날짜: 2026-04-02
> 커밋: `55226cf` → `hyoukj-png/webstart` main

---

## 작업 개요

WebStart 1인 웹 에이전시 AI 시스템(SETUP-GUIDE.md + 13개 스킬 파일)을 전수 검토하고
발견된 14건의 이슈를 모두 수정하여 커밋·푸시.

---

## 검토 범위

| 파일 | 설명 |
|------|------|
| `SETUP-GUIDE.md` | 설치 및 사용 가이드 |
| `skills/webstart/SKILL.md` | 프로젝트 초기 세팅 |
| `skills/pm/SKILL.md` | PM 기획 |
| `skills/design/SKILL.md` | 디자인 시스템 |
| `skills/contract/SKILL.md` | API 계약 확정 |
| `skills/fe/SKILL.md` | 프론트엔드 개발 |
| `skills/be/SKILL.md` | 백엔드 개발 |
| `skills/qa-check/SKILL.md` | QA 체크리스트 |
| `skills/devops/SKILL.md` | 배포 설정 |
| `skills/audit/SKILL.md` | 검수 오케스트레이터 |
| `skills/audit-ux/SKILL.md` | UX 분석 |
| `skills/audit-ia/SKILL.md` | IA 분석 |
| `skills/audit-tech/SKILL.md` | 기술 스택 분석 |
| `skills/audit-db/SKILL.md` | DB 유추 |

---

## 발견 및 수정 내역

### Critical — 동작 오류 (3건)

#### C-1. Playwright 실행 모델과 설치 방식 불일치
- **발견**: `audit/SKILL.md`가 존재하지 않는 `npx playwright test -e` 플래그 사용.
  근본 원인은 더 깊음 — SETUP-GUIDE가 `npm install -g playwright`(글로벌 CLI)로 안내하지만
  스킬들은 `require('playwright')`(로컬 npm 패키지) 방식을 사용해 MODULE_NOT_FOUND 발생.
- **수정**:
  - `audit/SKILL.md` Step 0에서 `_audit/` 폴더에 playwright를 로컬 자동 설치하는 명령 추가
  - `audit/audit-ux/audit-ia/audit-tech/audit-db` 5개 스킬의 `require('playwright')` →
    `require('./_audit/node_modules/playwright')`로 경로 통일
  - `SETUP-GUIDE.md` 전역 설치 안내 제거 → "실행 시 자동 설치" 안내로 교체

#### C-2. `/qa` vs `/qa-check` 스킬명 혼재
- **발견**: `fe/be/devops` 스킬의 완료 메시지와 게이트 메시지가 존재하지 않는 `/qa`를 안내.
  (제작 파이프라인 QA 스킬명은 `/qa-check`)
- **수정**: 3개 파일 일괄 수정
  - `fe/SKILL.md`: `다음 단계: /qa` → `/qa-check`
  - `be/SKILL.md`: `다음 단계: /qa` → `/qa-check`
  - `devops/SKILL.md`: `먼저 /qa 를 실행하고` → `/qa-check`

#### C-3. `--step=report` 옵션 미처리
- **발견**: `audit-db` 완료 메시지에서 `/audit --step=report` 실행을 안내하지만,
  `audit/SKILL.md` 옵션 처리에 해당 옵션이 없어 실행해도 아무 동작 안 함.
- **수정**: `audit/SKILL.md` Step 0 옵션 목록에 `--step=report → Step 5~6 실행` 추가

---

### Major — 기능 저하/불일치 (5건)

#### M-0. webstart 생성 CLAUDE.md의 호출 방식·파이프라인이 공식 흐름과 충돌 *(초기 검토에서 누락, 피드백 반영)*
- **발견**: webstart가 프로젝트에 생성하는 CLAUDE.md 템플릿과 완료 안내에 두 가지 오류.
  1. `@pm/@design/@fe/@be/@qa/@devops` 사용 — Claude.ai Projects 문법으로 CLI에서 동작 안 함.
     공식 호출 방식은 `/pm /design` 등 slash command.
  2. 파이프라인에서 `/contract` 단계 통째로 누락.
     `@pm → @design → @fe + @be → @qa → @devops`로 안내해 계약 미확정 상태로 병렬 개발 진행.
- **수정**: `webstart/SKILL.md`
  - CLAUDE.md 템플릿의 에이전트 역할 가이드 전체 `@` → `/` 변환
  - `/contract` 단계 및 역할 설명 추가
  - 파이프라인 순서를 6단계로 수정 (`/pm → /design → /contract → /fe+/be → /qa-check → /devops`)
  - `client-brief.md` 템플릿 안내문 `@pm 에게 전달` → `/pm 을 실행`
  - Step 5 완료 메시지 표를 7단계 전체 흐름으로 교체

#### M-1. webstart 폴더 구조 명세에 파일 누락
- **발견**: Step 2 폴더 구조에 `contract.md`, `status.md`, `handover.md` 미기재.
- **수정**: `_agency/` 구조에 3개 파일 추가, 생성 스킬 출처 주석 명시

#### M-2. `contract` 스킬의 PHP 스택 분기 없음
- **발견**: PHP 스택에서도 TypeScript 공유 타입만 생성. `fe/be/design`은 스택 분기가 있는데
  `contract`만 누락.
- **수정**: `contract/SKILL.md`
  - Step 2로 `CLAUDE.md` 스택 확인 단계 추가
  - 공유 타입: Next.js → TypeScript, PHP → OpenAPI YAML 분기
  - 인증 플로우: Next.js → Supabase Auth, PHP → Laravel Sanctum/Breeze 분기
  - Step 번호 전체 1씩 조정

#### M-3. `fe`/`be` 부분 작업 완료 시 전체 완료로 status 표시
- **발견**: `/fe Hero섹션`처럼 args로 일부만 구현해도 `status.md`의 FE/BE를 ✅ 완료로
  업데이트해 `/qa-check` 게이트를 조기 통과.
- **수정**: `fe/SKILL.md`, `be/SKILL.md`
  - `plan.md` 전체 항목 `[x]` 완료 시에만 status 업데이트
  - 완료 메시지를 전체 완료 / 부분 완료 두 가지로 분기

#### M-4. ~~audit-db/ia 게이트 단계 번호 혼용~~ → Minor 재분류
- 피드백: LLM이 자연어로 읽는 구조라 실제 오동작 경로 없음. 문서 명확성 이슈로 재분류.

---

### Minor — 표현/문서 개선 (6건)

| # | 항목 | 수정 내용 |
|---|------|----------|
| m-1 | SETUP-GUIDE Playwright 표현 | C-1 처리 시 함께 해결 |
| m-2 | `/audit --step` vs `/audit-ux` 중복 | 개별 실행(권장)과 재실행 용도 명확히 분리, `--step=report` 추가 |
| m-3 | 설치 확인 cleanup 안내 없음 | `rm -rf test-project/` 안내 인라인 추가 |
| m-4 | design 타이포그래피 템플릿 불완전 | H2/H3/Body/Small/Caption 행 각각 명시 |
| m-5 | qa-check 불필요한 Bash 도구 | `allowed-tools`에서 Bash 삭제 |
| m-6 | pm 단가 하드코딩 | `시간당 5만원` → `client-brief.md 기준`, 템플릿에 단가 입력 필드 추가 |
| m-7 | audit-ia/db 단계 번호 표기 | `UX 단계(Step 1)` → `UX 단계`, `IA 단계(Step 2)와 Tech 단계(Step 3)` → `IA 단계와 Tech 단계` |

---

## 수정 파일 목록

```
SETUP-GUIDE.md
skills/webstart/SKILL.md
skills/pm/SKILL.md
skills/design/SKILL.md
skills/contract/SKILL.md
skills/fe/SKILL.md
skills/be/SKILL.md
skills/qa-check/SKILL.md
skills/devops/SKILL.md
skills/audit/SKILL.md
skills/audit-ux/SKILL.md
skills/audit-ia/SKILL.md
skills/audit-tech/SKILL.md
skills/audit-db/SKILL.md
```

---

## 검토 과정 메모

초기 REVIEW-REPORT.md 작성 후 사용자 피드백으로 3가지 수정:

1. **webstart 사용자 경로 오류(M-0) 누락** — 폴더 구조 이슈(M-1)만 잡고
   더 큰 문제인 `@command` 방식과 Contract 단계 누락을 놓침. 추가 반영.

2. **C-1 수정안이 근본 원인까지 못 잡음** — "잘못된 플래그"만 지적하고
   "설치 방식(글로벌 CLI) vs 실행 방식(로컬 require) 불일치"를 누락.
   수정안도 같은 환경에서 실패함을 확인 후 로컬 자동 설치 방식으로 변경.

3. **M-4 심각도 과장** — "오동작 가능"으로 단정했으나 실제 파싱 코드가 없어
   기능 오류가 아닌 문서 명확성 이슈. Minor로 재분류.
