#!/bin/bash
# 1인 웹 에이전시 AI 시스템 — 자동 설치 스크립트
# 사용법: bash install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "=== 1인 웹 에이전시 AI 시스템 설치 시작 ==="
echo ""

# Claude Code 설치 여부 확인
if ! command -v claude &> /dev/null; then
  echo "[오류] Claude Code가 설치되어 있지 않습니다."
  echo "       설치: npm install -g @anthropic-ai/claude-code"
  exit 1
fi

SKILLS_SRC="$SCRIPT_DIR/skills"
SKILLS_DEST="$HOME/.claude/skills"

# 스킬 디렉토리 존재 확인
if [ ! -d "$SKILLS_SRC" ]; then
  echo "[오류] skills 폴더를 찾을 수 없습니다: $SKILLS_SRC"
  exit 1
fi

# 각 스킬 설치
for skill_dir in "$SKILLS_SRC"/*/; do
  skill_name=$(basename "$skill_dir")
  dest="$SKILLS_DEST/$skill_name"
  mkdir -p "$dest"
  cp "$skill_dir/SKILL.md" "$dest/SKILL.md"
  echo "[완료] /$skill_name 스킬 설치"
done

echo ""
echo "=== 설치 완료 ($(ls "$SKILLS_SRC" | wc -l | tr -d ' ')개 스킬) ==="
echo ""
echo "설치된 스킬:"
echo ""
echo "  [제작 파이프라인]"
echo "  /webstart     → 새 프로젝트 폴더 세팅"
echo "  /pm           → 기획·견적"
echo "  /design       → 디자인 시스템"
echo "  /contract     → API 계약 확정 (FE/BE 병렬 전)"
echo "  /fe           → 프론트엔드 개발"
echo "  /be           → 백엔드 개발"
echo "  /qa-check     → QA 체크리스트"
echo "  /devops       → 배포 설정"
echo ""
echo "  [검수 파이프라인]"
echo "  /audit        → 검수 오케스트레이터 (기존 사이트 분석)"
echo "  /audit-ux     → UI/UX 리서치 (컬러·폰트·컴포넌트)"
echo "  /audit-ia     → 정보 구조 분석 (사이트맵·IA)"
echo "  /audit-tech   → 기술 스택 진단 (프레임워크·성능)"
echo "  /audit-db     → 데이터 구조 유추 (ERD·API)"
echo ""
echo "다음 단계:"
echo "  1. Claude Code를 재시작하세요."
echo "  2. 새 프로젝트 시작: /webstart 프로젝트명 nextjs"
echo "  3. 기존 사이트 분석: /audit https://example.com"
echo ""
echo "Claude.ai Projects 설정은 SETUP-GUIDE.md 의 Step 2를 참고하세요."
echo ""
