---
name: webstart
description: Codex guide for the WebStart operating system and its agent-aware workflow
---

# WebStart Codex Skill

Codex에서 이 저장소를 다룰 때는 Claude 전용 명령 흐름을 그대로 복제하지 말고, 이 프로젝트의 Codex 문서를 기준으로 작업한다.

## 우선 읽을 문서

- `AGENT-PORTABILITY.md`
- `CODEX-GUIDE.md`
- `CODEX-MAPPING.md`
- `README.md`
- `SETUP-GUIDE.md`

## 설치

```bash
bash install.sh --agent codex
```

## 작업 원칙

- Claude Code용 `skills/*/SKILL.md`는 원본 문서로 존중한다.
- Codex 작업은 명시적 절차와 체크리스트로 진행한다.
- 새 문서를 만들 때는 기존 Claude 문서와 역할이 겹치지 않게 한다.
- install script나 guide를 바꿀 때는 Codex 문서와 함께 맞춘다.

## 첫 점검

- `~/.webstart/bin/webstart-audit doctor`
- `bash scripts/lint-docs.sh`

## 대응표

필요하면 `CODEX-MAPPING.md`를 따라 Claude 명령과 Codex 절차를 대응시킨다.
