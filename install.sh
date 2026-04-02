#!/bin/bash
# 1인 웹 에이전시 AI 시스템 — 자동 설치 스크립트
# 사용법: bash install.sh

set -e

echo ""
echo "=== 1인 웹 에이전시 AI 시스템 설치 시작 ==="
echo ""

# Claude Code 설치 여부 확인
if ! command -v claude &> /dev/null; then
  echo "[오류] Claude Code가 설치되어 있지 않습니다."
  echo "       설치: npm install -g @anthropic-ai/claude-code"
  exit 1
fi

# /webstart 스킬 설치
SKILL_DIR="$HOME/.claude/skills/webstart"
mkdir -p "$SKILL_DIR"
cp "$(dirname "$0")/skills/webstart/SKILL.md" "$SKILL_DIR/SKILL.md"
echo "[완료] /webstart 스킬 설치: $SKILL_DIR/SKILL.md"

echo ""
echo "=== 설치 완료 ==="
echo ""
echo "다음 단계:"
echo "  1. Claude Code를 재시작하세요."
echo "  2. /webstart 명령어가 스킬 목록에 나타나는지 확인하세요."
echo "  3. 새 프로젝트 시작: /webstart 프로젝트명 nextjs"
echo ""
echo "Claude.ai Projects 설정은 SETUP-GUIDE.md 의 Step 2를 참고하세요."
echo ""
