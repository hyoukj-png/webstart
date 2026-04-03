# WebStart Codex 빠른 시작

1. 저장소를 클론한다.

```bash
git clone https://github.com/hyoukj-png/webstart.git
cd WebStart
```

2. Codex 모드로 설치한다.

```bash
bash install.sh --agent codex
```

3. 가이드를 읽는다.

```bash
sed -n '1,120p' AGENT-PORTABILITY.md
sed -n '1,120p' CODEX-GUIDE.md
sed -n '1,120p' CODEX-MAPPING.md
```

4. 작업을 시작한다.

- 새 프로젝트면 `agency-ai-agent-plan.md`와 `README.md`를 먼저 본다.
- 기존 사이트 분석이면 `web-audit-agent-plan.md`와 `CODEX-MAPPING.md`를 먼저 본다.

5. 상태를 확인한다.

```bash
~/.webstart/bin/webstart-audit doctor
bash scripts/lint-docs.sh
```
