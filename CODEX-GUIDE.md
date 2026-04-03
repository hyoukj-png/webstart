# WebStart Codex 가이드

> 대상: Codex로 이 저장소를 사용하는 경우
> 원칙: Claude Code용 원본 문서는 유지하고, Codex는 이 가이드를 중심으로 작업한다.

---

## 1. 이 문서의 역할

이 저장소는 기본적으로 Claude Code용 운영 체계로 완성되어 있다.
Codex에서 이 프로젝트를 쓰려면, Claude 전용 명령 흐름을 그대로 따라가기보다 Codex용 호환 레이어를 읽는 편이 낫다.

이 가이드는 Codex가 WebStart 저장소를 처음 열었을 때 읽어야 할 기준 문서다.
공용 기준이 필요하면 먼저 `AGENT-PORTABILITY.md`를 읽는다.

---

## 2. 설치

### 권장 설치

```bash
git clone https://github.com/hyoukj-png/webstart.git
cd WebStart
bash install.sh --agent codex
```

설치 결과:

- `codex-skills/webstart/SKILL.md`가 `~/.codex/skills/webstart/`로 복사된다.
- 공용 `audit-runtime/`이 `~/.webstart/audit-runtime`에 설치된다.
- 문서 일관성 검사가 실행된다.
- 먼저 공용 기준은 `AGENT-PORTABILITY.md`를 보고, 이어서 이 가이드를 읽는다.

### 선택 사항

검수 런타임이 필요 없으면 다음처럼 건너뛸 수 있다.

```bash
bash install.sh --agent codex --skip-audit-runtime
```

---

## 3. 사용 원칙

- Claude Code용 `skills/*/SKILL.md`는 원본 문서로 존중한다.
- Codex는 `CODEX-GUIDE.md`와 `CODEX-MAPPING.md`를 기준으로 움직인다.
- 설치 명령은 명시적으로 선택한다.
- 자동 추정은 보조 수단일 뿐, 기본 판단 근거로 쓰지 않는다.

---

## 4. 작업 흐름

### 새 프로젝트

1. 프로젝트 요구사항을 확인한다.
2. `CODEX-MAPPING.md`에서 해당 작업의 대응 절차를 찾는다.
3. 필요한 경우 `agency-ai-agent-plan.md`를 참고한다.
4. `README.md`와 `SETUP-GUIDE.md`의 Codex 섹션을 따른다.
5. 파일 변경 후 검증을 수행한다.

### 기존 사이트 분석

1. `web-audit-agent-plan.md`를 읽는다.
2. `CODEX-MAPPING.md`에서 `/audit` 계열 대응 절차를 확인한다.
3. `~/.webstart/bin/webstart-audit doctor`로 런타임 상태를 확인한다.
4. 결과를 다시 제작 파이프라인으로 넘길지 판단한다.

---

## 5. 자주 보는 문서

- `README.md`
- `SETUP-GUIDE.md`
- `AGENT-PORTABILITY.md`
- `CODEX-MAPPING.md`
- `agency-ai-agent-plan.md`
- `web-audit-agent-plan.md`

---

## 6. 주의점

- Claude 전용 문서를 Codex용으로 그대로 복제해 다시 만들지 않는다.
- 문서 충돌이 생기면 Claude 원본을 수정하기 전에 Codex 가이드를 먼저 맞춘다.
- 에이전트별 설치 옵션을 바꿀 때는 `install.sh`와 이 가이드를 함께 갱신한다.
