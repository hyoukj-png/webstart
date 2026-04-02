# WebStart 변경 이력

## v2.1 — 2026-04-02 (검수 파이프라인 추가)

### 신규 기능

**검수 에이전트 팀 (Agent 5~8)**

기존 웹사이트를 역설계하여 제작 팀에 인계하는 5개 스킬 추가.

| 스킬 | 역할 | 주요 기능 |
|------|------|----------|
| `/audit` | 오케스트레이터 | 대상 등록, Playwright 자동 수집, 종합 보고서, client-brief.md 변환 |
| `/audit-ux` | UI/UX 리서처 | 컬러/폰트/컴포넌트 추출, 접근성 검수 |
| `/audit-ia` | 정보 아키텍트 | 사이트맵 역추적, 사용자 여정, SEO 메타데이터 |
| `/audit-tech` | 기술 스택 진단 | 프레임워크 감지, CWV 측정, 서드파티 분석 |
| `/audit-db` | DB 유추 | API 증거 기반 ERD 역설계, 입력 게이트 판정 |

### 구조 변경

- 파이프라인 Step 0~6 체계 (기존 Step 1~5에서 확장)
- Step 0: 분석 대상 등록 (`_audit/target.md` 템플릿)
- Step 5: 종합 보고서 (`known gaps` 섹션 강제)
- Step 6: 제작 팀 인계 (`_agency/client-brief.md` 자동 생성)

### 공통 규칙 추가

- **신뢰도 분류 체계:** Confirmed / Likely / Hypothesis / Unknown
- **보안 정책:** PII 마스킹, 인증 정보 저장 금지, rate limit 준수
- **입력 게이트:** `/audit-db`에서 API 증거 유무에 따른 산출물 신뢰 등급 분류

### 파일 변경

| 파일 | 상태 |
|------|------|
| `skills/audit/SKILL.md` | 신규 |
| `skills/audit-ux/SKILL.md` | 신규 |
| `skills/audit-ia/SKILL.md` | 신규 |
| `skills/audit-tech/SKILL.md` | 신규 |
| `skills/audit-db/SKILL.md` | 신규 |
| `web-audit-agent-plan.md` | 신규 (v1.1) |
| `web-audit-agent-plan-review-report.md` | 신규 |
| `web-audit-agent-plan-revision-report.md` | 신규 |
| `install.sh` | 수정 (5개 스킬 안내 추가) |
| `SETUP-GUIDE.md` | 수정 (v2.0 전면 개정) |

---

## v2.0 — 2026-04-02 (제작 파이프라인 v2)

### 주요 변경

- @mode 방식에서 독립 스킬 8개로 전환
- Contract Freeze 단계 추가 (`/contract`)
- 파이프라인 게이트 강제화 (`_agency/status.md` 자동 검증)
- PHP 스택 분기 지원
- 범위 변경 규칙 추가

### 스킬 목록 (8개)

| 스킬 | 역할 |
|------|------|
| `/webstart` | 프로젝트 초기 세팅 |
| `/pm` | 기획, 견적 |
| `/design` | 디자인 시스템 |
| `/contract` | API 계약 확정 |
| `/fe` | 프론트엔드 개발 |
| `/be` | 백엔드 개발 |
| `/qa-check` | QA 체크리스트 |
| `/devops` | 배포 설정 |

---

## v1.0 — 2026-04-02 (초기 버전)

- CLAUDE.md @mode 전환 방식
- 6개 에이전트 (PM, 디자이너, FE, BE, QA, DevOps)
