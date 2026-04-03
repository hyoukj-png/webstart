# WebStart 에이전트 포터빌리티 안내서

> 대상: 다른 프로젝트, 다른 에이전트, 처음 보는 협업자
> 목적: 이 저장소에서 무엇이 원본이고 무엇이 호환 레이어인지 빠르게 이해시키기

---

## 1. 한 줄 요약

WebStart는 원래 Claude Code용으로 완성된 웹 에이전시 운영 체계다.
지금은 Codex용 호환 레이어도 추가되어 있으며, 앞으로 다른 에이전트도 같은 방식으로 확장할 수 있게 설계했다.

현재 Codex 포팅 범위는 공용 안내서, 설치 분기, 그리고 `webstart` Codex 진입 문서 중심이다.
Claude Code의 13개 스킬 체계는 원본으로 유지된다.

---

## 2. 문서 우선순위

### 원본

- `README.md`
- `SETUP-GUIDE.md`
- `CHANGELOG.md`
- `agency-ai-agent-plan.md`
- `web-audit-agent-plan.md`
- `skills/*/SKILL.md`
- `audit-runtime/`

### 호환 레이어

- `CODEX-GUIDE.md`
- `CODEX-MAPPING.md`
- `CODEX-QUICKSTART.md`
- `codex-skills/`

### 역사 문서

- `IMPROVEMENT-REPORT.md`
- `REVIEW-REPORT.md`
- `REVIEW-REPORT-V2.md`
- `SESSION-REPORT.md`
- `CODEX-PORTING-PLAN.md`

---

## 3. 지원하는 실행 모드

### Claude Code

기본 모드다.

```bash
bash install.sh
```

### Codex

호환 레이어가 설치된다.

```bash
bash install.sh --agent codex
```

### 앞으로의 확장

`install.sh --agent <name>` 구조로 새 에이전트를 추가할 수 있다.
다만 새 에이전트가 실제로 지원되기 전에는 문서만 추가하지 말고 설치/검증까지 같이 맞춰야 한다.

---

## 4. 이 저장소를 처음 보는 사람이 읽는 순서

1. `README.md`
2. `AGENT-PORTABILITY.md`
3. 자신의 에이전트에 맞는 가이드
4. `SETUP-GUIDE.md`
5. 필요 시 파이프라인 설계 문서

---

## 5. 에이전트별 해석 기준

### Claude Code

- slash command와 `skills/*/SKILL.md`를 직접 사용한다.
- 제작 파이프라인과 검수 파이프라인의 원본이다.
- 현재 가장 풍부한 문서가 이 경로다.

### Codex

- Claude command를 그대로 복제하지 않고 절차서로 읽는다.
- `CODEX-GUIDE.md`와 `CODEX-MAPPING.md`를 기준으로 작업한다.
- 설치는 `bash install.sh --agent codex`를 쓴다.

### 기타 에이전트

- 우선 이 문서를 읽고 원본/호환/역사를 구분한다.
- 그다음 `install.sh --agent <name>` 패턴을 그대로 따라갈지 결정한다.
- 확장 전에 문서 충돌이 없는지 확인한다.

---

## 6. 혼동 방지 규칙

- 역사 문서는 현재 작업 목록으로 읽지 않는다.
- Claude 문서는 원본으로 유지한다.
- Codex 문서는 호환 레이어로만 유지한다.
- 설치 옵션이 바뀌면 README, SETUP-GUIDE, 에이전트 가이드를 함께 갱신한다.
- “이건 Claude 전용인가, 에이전트 공용인가”를 항상 먼저 구분한다.

---

## 7. 다른 프로젝트로 가져갈 때

이 저장소를 다른 프로젝트에 복제하거나 참고할 때는 다음 순서가 안전하다.

1. `AGENT-PORTABILITY.md`를 먼저 읽는다.
2. `install.sh --agent <name>` 구조를 유지할지 결정한다.
3. Claude 원본과 호환 레이어를 분리한다.
4. 역사 문서는 현재 지침에서 제외한다.
5. 새 에이전트가 있으면 매핑표를 추가한다.

---

## 8. 운영 팁

- 새 에이전트 추가는 “설치 스크립트 + 가이드 + 매핑표” 3종 세트로 처리한다.
- 문서만 늘리고 설치를 안 맞추면 오히려 혼동이 커진다.
- 어떤 에이전트든 먼저 읽어야 하는 문서는 작고 명확해야 한다.
