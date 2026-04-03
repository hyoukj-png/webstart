# WebStart Codex 매핑표

> 이 문서는 Claude Code용 명령과 Codex용 작업 절차를 1:1로 대응한다.
> 다른 프로젝트나 다른 에이전트는 `AGENT-PORTABILITY.md`를 먼저 읽고 이 표를 참조한다.

| Claude 기준 | Codex 기준 | 참고 문서 |
|-------------|------------|-----------|
| `/webstart` | 새 프로젝트 부트스트랩 절차 실행 | `agency-ai-agent-plan.md`, `CODEX-GUIDE.md` |
| `/pm` | 요구사항 정리 및 `client-brief` 초안 작성 | `skills/pm/SKILL.md` |
| `/design` | 디자인 시스템/레이아웃 초안 작성 | `skills/design/SKILL.md` |
| `/contract` | FE/BE 경계와 API 계약 정의 | `skills/contract/SKILL.md` |
| `/fe` | 프론트엔드 구현 | `skills/fe/SKILL.md` |
| `/be` | 백엔드 구현 | `skills/be/SKILL.md` |
| `/qa-check` | 배포 전 QA 게이트 확인 | `skills/qa-check/SKILL.md` |
| `/devops` | 배포 및 인계 정리 | `skills/devops/SKILL.md` |
| `/audit --full` | 기존 사이트 전체 검수 | `web-audit-agent-plan.md` |
| `/audit-ux` | 시각/컴포넌트 수집 | `skills/audit-ux/SKILL.md` |
| `/audit-ia` | 정보 구조 분석 | `skills/audit-ia/SKILL.md` |
| `/audit-tech` | 기술 스택/성능 분석 | `skills/audit-tech/SKILL.md` |
| `/audit-db` | 데이터/API 추정 | `skills/audit-db/SKILL.md` |

## 해석 규칙

- Claude의 slash command는 실행 인터페이스다.
- Codex에서는 같은 의미를 절차와 체크리스트로 표현한다.
- 의미가 같은 규칙은 유지하고, 입력 방식만 Codex 친화적으로 바꾼다.
