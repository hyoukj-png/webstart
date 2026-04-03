#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

ERRORS=0
TMP_OUTPUT="$(mktemp)"
trap 'rm -f "$TMP_OUTPUT"' EXIT

search_matches() {
  local pattern="$1"
  shift

  if command -v rg >/dev/null 2>&1; then
    rg -n -S "$pattern" "$@" >"$TMP_OUTPUT" 2>/dev/null
  else
    grep -R -n -E "$pattern" "$@" >"$TMP_OUTPUT" 2>/dev/null
  fi
}

check_no_match() {
  local pattern="$1"
  local message="$2"
  shift 2

  if search_matches "$pattern" "$@"; then
    echo "[ERROR] $message"
    cat "$TMP_OUTPUT"
    ERRORS=$((ERRORS + 1))
  fi
}

VALID_SKILLS=(
  webstart
  pm
  design
  contract
  fe
  be
  qa-check
  devops
  audit
  audit-ux
  audit-ia
  audit-tech
  audit-db
)

for skill in "${VALID_SKILLS[@]}"; do
  if [ ! -f "skills/$skill/SKILL.md" ]; then
    echo "[ERROR] skills/$skill/SKILL.md 없음"
    ERRORS=$((ERRORS + 1))
  fi
done

check_no_match "@pm|@design|@contract|@fe|@be|@qa|@devops" \
  "@command 방식 발견 (/command 로 유지 필요)" \
  SETUP-GUIDE.md \
  skills/webstart/SKILL.md \
  skills/pm/SKILL.md \
  skills/design/SKILL.md \
  skills/contract/SKILL.md \
  skills/fe/SKILL.md \
  skills/be/SKILL.md \
  skills/qa-check/SKILL.md \
  skills/devops/SKILL.md

check_no_match "/qa([^a-zA-Z-]|$)" \
  "제작 파이프라인 파일에 /qa 참조 발견 (/qa-check 사용 필요)" \
  skills/fe/SKILL.md \
  skills/be/SKILL.md \
  skills/devops/SKILL.md

check_no_match "npm install -g playwright|npx playwright install chromium" \
  "구식 Playwright 전역 설치 안내 발견" \
  CHANGELOG.md \
  SETUP-GUIDE.md \
  skills/audit/SKILL.md \
  skills/audit-ux/SKILL.md \
  skills/audit-ia/SKILL.md \
  skills/audit-tech/SKILL.md \
  skills/audit-db/SKILL.md

check_no_match "6개 에이전트" \
  "webstart 소개 문구가 구버전 스킬 수를 가리킴" \
  skills/webstart/SKILL.md

check_no_match "분석 목적:\\*\\* \\(사용자에게 질문\\)" \
  "audit --full 자동화 경로에 수동 질문 문구가 남아 있음" \
  skills/audit/SKILL.md

for skill_file in \
  skills/pm/SKILL.md \
  skills/design/SKILL.md \
  skills/contract/SKILL.md \
  skills/fe/SKILL.md \
  skills/be/SKILL.md \
  skills/qa-check/SKILL.md \
  skills/devops/SKILL.md
do
  if ! grep -q "_agency/status.json" "$skill_file"; then
    echo "[ERROR] $skill_file 에 _agency/status.json 기준이 없음"
    ERRORS=$((ERRORS + 1))
  fi
done

if [ "$ERRORS" -eq 0 ]; then
  echo "✅ 문서 일관성 검사 통과"
else
  exit 1
fi
