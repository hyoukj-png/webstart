# WebStart Codex 포팅 계획서

> 작성일: 2026-04-03
> 상태: 반영 완료
> 원칙: 현재 완성된 Claude Code용 문서는 그대로 유지하고, Codex용 호환 레이어를 별도로 추가한다.

---

## 1. 배경

이 저장소는 현재 `Claude Code` 기준으로 완성되어 있다.
`skills/*/SKILL.md`, `install.sh`, `README.md`, `SETUP-GUIDE.md`, 각 파이프라인 계획서는 모두 Claude Code의 실행 방식과 문서 흐름을 전제로 한다.

문제는 다른 컴퓨터나 다른 프로젝트에서 GitHub로 설치할 때, 사용자가 Claude Code가 아닌 `Codex`로 이 체계를 쓰고 싶어도 현재는 진입점이 하나뿐이라는 점이다.

이 계획은 그 문제를 해결하기 위해, 기존 Claude 체계를 유지한 채 Codex용 설치/운영 방식을 별도 경로로 포팅하는 방안을 정의한다.

---

## 2. 목표

- 현재 완성된 Claude Code용 운영 체계를 깨지 않는다.
- Codex에서 읽고 실행할 수 있는 별도 문서와 설치 경로를 제공한다.
- 설치 시 에이전트 종류를 명시적으로 선택할 수 있게 한다.
- 자동 판별은 보조 수단으로만 두고, 기본은 명시적 선택으로 유지한다.
- 나중에 Gemini 같은 다른 에이전트도 같은 방식으로 확장할 수 있게 한다.

---

## 3. 권장 구조

### 3.1 단일 저장소, 다중 에이전트 진입점

하나의 저장소를 유지하되 설치 진입점은 에이전트별로 분리한다.

권장 형태:

```bash
bash install.sh --agent claude
bash install.sh --agent codex
bash install.sh --agent gemini
```

`--agent`를 생략하면 기본값은 `claude`로 둔다.
이렇게 해야 기존 사용자의 설치 흐름이 바뀌지 않고, Codex 사용자는 명시적으로 자신의 경로를 선택할 수 있다.

### 3.2 자동 판별은 보조 수단

자동 판별은 다음 수준까지만 허용한다.

- `WEBSTART_AGENT` 환경변수로 우선 선택
- `--agent` 옵션이 없으면 기본값 `claude`
- 현재 실행 환경이 명확히 Codex일 때만 안내 메시지에서 선택을 유도

자동으로 “추정”해서 설치 대상을 바꾸는 방식은 쓰지 않는다.
그 방식은 한 번은 편해 보여도, 나중에 설치 결과가 섞여서 유지보수 비용이 커진다.

---

## 4. 포팅 범위

### 4.1 유지할 것

- `README.md`
- `SETUP-GUIDE.md`
- `CHANGELOG.md`
- `agency-ai-agent-plan.md`
- `web-audit-agent-plan.md`
- 현재 `skills/*/SKILL.md`
- 현재 `audit-runtime/`

### 4.2 새로 추가할 것

- `CODEX-GUIDE.md`
- `CODEX-MAPPING.md`
- 필요 시 `CODEX-QUICKSTART.md`

### 4.3 수정할 것

- `install.sh`
- `README.md`
- `SETUP-GUIDE.md`

기존 Claude 문서의 내용을 뜯어고치기보다, Codex용 설명을 옆에 붙이는 방향으로 간다.

---

## 5. 문서 설계

### 5.1 `CODEX-GUIDE.md`

Codex에서 이 저장소를 사용하는 전체 안내서다.

포함할 내용:

- 이 프로젝트의 목적
- Claude Code 문서와 Codex 문서의 관계
- 설치 전 준비 사항
- `--agent codex` 설치 예시
- 작업 흐름 요약
- 자주 막히는 지점

### 5.2 `CODEX-MAPPING.md`

Claude 전용 표현을 Codex 친화적 절차로 바꾸는 대응표다.

예시:

- `/webstart` → `Codex용 프로젝트 부트스트랩 절차`
- `/pm` → `Codex용 기획 체크리스트`
- `/design` → `Codex용 디자인 체크리스트`
- `/fe`, `/be`, `/qa-check`, `/devops` → `Codex용 실행 순서와 승인 기준`

### 5.3 `CODEX-QUICKSTART.md`

처음 쓰는 사람이 바로 따라 할 수 있는 최소 절차다.

포함할 내용:

- 저장소 클론
- `bash install.sh --agent codex`
- 첫 작업 시작
- 성공 확인 명령

---

## 6. 설치 전략

### 6.1 권장안: `install.sh --agent <name>`

단일 설치 스크립트에 에이전트 옵션을 추가한다.

권장 이유:

- 사용자 입장에서 기억하기 쉽다
- 설치 로직이 한 군데에 모인다
- 새 에이전트를 추가해도 확장하기 쉽다
- Claude 사용자를 깨지 않는다

### 6.2 대안: 에이전트별 별도 설치 명령

예:

```bash
bash install-claude.sh
bash install-codex.sh
```

이 방식은 초기에 이해하기는 쉬울 수 있지만, 시간이 지나면 스크립트가 여러 개로 갈라져 유지보수가 어려워진다.

따라서 별도 스크립트는 최종 해법이 아니라, 필요 시 `install.sh`를 감싸는 thin wrapper 정도로만 둔다.

---

## 7. 구현 단계

### Phase 0. 규칙 분류

- Claude 전용 문서
- Codex 공용 문서
- 에이전트 비의존 규칙
- 설치 시 분기해야 하는 규칙

### Phase 1. 설치 분기

- `install.sh`에 `--agent` 옵션 추가
- `WEBSTART_AGENT` 환경변수 지원
- 기본값은 `claude`
- 설치 대상 경로를 에이전트별로 분리

### Phase 2. Codex 문서 추가

- `CODEX-GUIDE.md` 작성
- `CODEX-MAPPING.md` 작성
- 필요하면 `CODEX-QUICKSTART.md` 추가

### Phase 3. README/SETUP-GUIDE 연결

- README에 Codex 안내를 별도 섹션으로 추가
- SETUP-GUIDE에 에이전트별 설치 예시를 추가
- 기존 Claude 절차는 그대로 유지

### Phase 4. 검증

- Claude 기본 설치가 그대로 동작하는지 확인
- Codex 설치가 새로 동작하는지 확인
- 문서 목록과 설치 명령이 서로 충돌하지 않는지 확인

---

## 8. 승인 기준

- 기존 Claude 설치가 변하지 않는다.
- Codex 설치 명령이 명시적으로 분리된다.
- Codex 사용자는 별도 문서만 읽어도 흐름을 이해한다.
- 문서 이름만으로 역사 문서와 현재 문서를 구분할 수 있다.
- 새 에이전트를 추가할 때 같은 패턴으로 확장할 수 있다.

---

## 9. 리스크

- 문서가 두 체계로 나뉘면 동기화 비용이 생긴다.
- 그래서 Codex 문서는 Claude 문서의 복제본이 아니라 호환 레이어여야 한다.
- 자동 판별을 과하게 넣으면 오작동 가능성이 커진다.
- 설치 스크립트가 너무 똑똑해지면 오히려 디버깅이 어려워진다.

---

## 10. 다음 결정 포인트

현재 채택한 방향은 `install.sh --agent <name>` 단일 설치 스크립트다.
Codex 문서는 `AGENT-PORTABILITY.md`를 공용 진입점으로 두고, `CODEX-GUIDE.md` / `CODEX-MAPPING.md` / `CODEX-QUICKSTART.md` 세트로 구성했다.

추가 확장 전에 아래 2가지를 다시 점검하면 된다.

1. 설치 진입점은 `install.sh --agent <name>` 단일 스크립트로 갈지
2. Codex 문서 초안을 `CODEX-GUIDE.md` / `CODEX-MAPPING.md` 둘로 시작할지, `CODEX-QUICKSTART.md`까지 같이 둘지

---

## 11. 상태 요약

- Claude Code용 원본 문서는 유지 중이다.
- Codex용 호환 레이어는 추가되었다.
- 공용 진입 안내는 `AGENT-PORTABILITY.md`가 담당한다.
- 앞으로 새 에이전트가 들어와도 같은 패턴으로 확장할 수 있다.

---

## 12. 권장 결론

이 저장소는 계속 Claude Code용 원본을 유지하고, Codex는 별도 호환 레이어로 포팅하는 것이 가장 안전하다.

즉:

- 원본: Claude Code용 현재 문서와 설치 흐름
- 추가: Codex용 설치 분기와 문서 묶음
- 자동 판별: 보조 기능만
- 기본값: Claude

이 방향이면 현재 완성된 구조를 잃지 않으면서도, 다른 에이전트로 확장할 수 있다.
