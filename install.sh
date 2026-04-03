#!/bin/bash
# 1인 웹 에이전시 AI 시스템 — 자동 설치 스크립트
# 사용법: bash install.sh [--agent claude|codex] [--skip-audit-runtime]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBSTART_HOME="${WEBSTART_HOME:-$HOME/.webstart}"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
AGENT="${WEBSTART_AGENT:-claude}"
SKIP_AUDIT_RUNTIME=0
MIN_NODE_MAJOR=18
MIN_PYTHON_MAJOR=3
MIN_PYTHON_MINOR=10

while [ $# -gt 0 ]; do
  case "$1" in
    --agent)
      shift
      if [ $# -eq 0 ]; then
        echo "[오류] --agent 뒤에 claude 또는 codex 를 지정해야 합니다."
        exit 1
      fi
      AGENT="$1"
      ;;
    --agent=*)
      AGENT="${1#*=}"
      ;;
    --skip-audit-runtime)
      SKIP_AUDIT_RUNTIME=1
      ;;
    -h|--help)
      echo "사용법: bash install.sh [--agent claude|codex] [--skip-audit-runtime]"
      exit 0
      ;;
    *)
      echo "[오류] 알 수 없는 옵션: $1"
      echo "       사용법: bash install.sh [--agent claude|codex] [--skip-audit-runtime]"
      exit 1
      ;;
  esac
  shift
done

case "$AGENT" in
  claude|codex) ;;
  *)
    echo "[오류] 지원하지 않는 agent 입니다: $AGENT"
    echo "       지원 값: claude, codex"
    exit 1
    ;;
esac

echo ""
echo "=== 1인 웹 에이전시 AI 시스템 설치 시작 ==="
echo ""

check_node_version() {
  if ! command -v node &> /dev/null; then
    echo "[오류] Node.js 가 설치되어 있지 않습니다."
    echo "       Node.js ${MIN_NODE_MAJOR}+ 필요: https://nodejs.org"
    exit 1
  fi

  NODE_VERSION=$(node -v 2>/dev/null | sed 's/^v//')
  NODE_MAJOR=$(printf '%s' "$NODE_VERSION" | cut -d. -f1)
  if [ -z "$NODE_MAJOR" ] || [ "$NODE_MAJOR" -lt "$MIN_NODE_MAJOR" ]; then
    echo "[오류] Node.js ${MIN_NODE_MAJOR}+ 가 필요합니다. 현재: ${NODE_VERSION:-unknown}"
    exit 1
  fi
}

check_python_version() {
  if ! command -v python3 &> /dev/null; then
    echo "[오류] python3 가 설치되어 있지 않습니다."
    echo "       Python ${MIN_PYTHON_MAJOR}.${MIN_PYTHON_MINOR}+ 필요: https://python.org"
    exit 1
  fi

  PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}")' 2>/dev/null)
  PYTHON_MAJOR=$(printf '%s' "$PYTHON_VERSION" | cut -d. -f1)
  PYTHON_MINOR=$(printf '%s' "$PYTHON_VERSION" | cut -d. -f2)
  if [ -z "$PYTHON_MAJOR" ] || [ -z "$PYTHON_MINOR" ]; then
    echo "[오류] Python 버전을 확인할 수 없습니다."
    exit 1
  fi
  if [ "$PYTHON_MAJOR" -lt "$MIN_PYTHON_MAJOR" ] || { [ "$PYTHON_MAJOR" -eq "$MIN_PYTHON_MAJOR" ] && [ "$PYTHON_MINOR" -lt "$MIN_PYTHON_MINOR" ]; }; then
    echo "[오류] Python ${MIN_PYTHON_MAJOR}.${MIN_PYTHON_MINOR}+ 가 필요합니다. 현재: ${PYTHON_VERSION}"
    exit 1
  fi
}

case "$AGENT" in
  claude)
    check_node_version
    # Claude Code 설치 여부 확인
    if ! command -v claude &> /dev/null; then
      echo "[오류] Claude Code가 설치되어 있지 않습니다."
      echo "       설치: npm install -g @anthropic-ai/claude-code"
      exit 1
    fi
    ;;
  codex)
    if ! command -v codex &> /dev/null; then
      echo "[안내] codex 명령을 찾을 수 없지만 Codex용 문서/스킬 설치는 계속 진행합니다."
    fi
    ;;
esac

if [ "$SKIP_AUDIT_RUNTIME" -eq 0 ]; then
  check_python_version
fi

case "$AGENT" in
  claude)
    AGENT_LABEL="Claude Code"
    SKILLS_SRC="$SCRIPT_DIR/skills"
    SKILLS_DEST="$CLAUDE_HOME/skills"
    ;;
  codex)
    AGENT_LABEL="Codex"
    SKILLS_SRC="$SCRIPT_DIR/codex-skills"
    SKILLS_DEST="$CODEX_HOME/skills"
    ;;
esac

AUDIT_RUNTIME_SRC="$SCRIPT_DIR/audit-runtime"
AUDIT_RUNTIME_DEST="$WEBSTART_HOME/audit-runtime"
AUDIT_RUNTIME_SETUP="$SCRIPT_DIR/scripts/setup-audit-runtime.sh"
DOC_LINT_SCRIPT="$SCRIPT_DIR/scripts/lint-docs.sh"

# 스킬 디렉토리 존재 확인
if [ ! -d "$SKILLS_SRC" ]; then
  echo "[오류] 스킬 소스 디렉토리를 찾을 수 없습니다: $SKILLS_SRC"
  exit 1
fi

# 각 스킬 설치
for skill_dir in "$SKILLS_SRC"/*/; do
  skill_name=$(basename "$skill_dir")
  dest="$SKILLS_DEST/$skill_name"
  mkdir -p "$dest"

  if command -v rsync &> /dev/null; then
    rsync -a --delete --exclude='._*' --exclude='__pycache__/' --exclude='*.pyc' "$skill_dir" "$dest/"
  else
    rm -rf "$dest"
    mkdir -p "$dest"
    cp -R "$skill_dir"/. "$dest"/
    find "$dest" -name '._*' -delete
    find "$dest" -name '__pycache__' -type d -exec rm -rf {} +
    find "$dest" -name '*.pyc' -type f -delete
  fi

  echo "[완료] /$skill_name 스킬 설치 ($AGENT_LABEL)"
done

# 공용 audit runtime 복사
if [ -d "$AUDIT_RUNTIME_SRC" ]; then
  mkdir -p "$WEBSTART_HOME"

  if command -v rsync &> /dev/null; then
    rsync -a --delete --exclude='._*' --exclude='__pycache__/' --exclude='*.pyc' "$AUDIT_RUNTIME_SRC"/ "$AUDIT_RUNTIME_DEST"/
  else
    rm -rf "$AUDIT_RUNTIME_DEST"
    mkdir -p "$AUDIT_RUNTIME_DEST"
    cp -R "$AUDIT_RUNTIME_SRC"/. "$AUDIT_RUNTIME_DEST"/
    find "$AUDIT_RUNTIME_DEST" -name '._*' -delete
    find "$AUDIT_RUNTIME_DEST" -name '__pycache__' -type d -exec rm -rf {} +
    find "$AUDIT_RUNTIME_DEST" -name '*.pyc' -type f -delete
  fi

  echo "[완료] 공용 audit runtime 동기화: $AUDIT_RUNTIME_DEST"
fi

if [ "$SKIP_AUDIT_RUNTIME" -eq 0 ] && [ -x "$AUDIT_RUNTIME_SETUP" ] && [ -d "$AUDIT_RUNTIME_DEST" ]; then
  echo ""
  echo "=== audit runtime 부트스트랩 ==="
  echo ""
  if bash "$AUDIT_RUNTIME_SETUP" "$AUDIT_RUNTIME_DEST"; then
    echo "[완료] audit runtime 설치"
  else
    echo "[경고] audit runtime 자동 설치에 실패했습니다."
    echo "       수동 실행: bash scripts/setup-audit-runtime.sh"
  fi
fi

if [ -f "$DOC_LINT_SCRIPT" ]; then
  echo ""
  echo "=== 문서 일관성 검사 ==="
  echo ""
  bash "$DOC_LINT_SCRIPT"
fi

echo ""
echo "=== 설치 완료 ($AGENT_LABEL, $(ls "$SKILLS_SRC" | wc -l | tr -d ' ')개 스킬) ==="
echo ""
echo "설치된 스킬:"
echo ""
if [ "$AGENT" = "claude" ]; then
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
  echo "  4. 고급 audit runtime 확인: ~/.webstart/bin/webstart-audit doctor"
  echo ""
  echo "Claude.ai Projects 설정은 SETUP-GUIDE.md 의 Step 2를 참고하세요."
else
  echo "  [Codex 호환 레이어]"
  echo "  /webstart     → Codex용 WebStart 가이드"
  echo ""
  echo "  Codex용 안내:"
  echo "  1. AGENT-PORTABILITY.md를 먼저 읽으세요."
  echo "  2. CODEX-GUIDE.md와 CODEX-MAPPING.md를 이어서 확인하세요."
  echo "  3. 프로젝트 루트에서 작업을 시작하세요."
  echo "  4. 공통 audit runtime 확인: ~/.webstart/bin/webstart-audit doctor"
  echo ""
  echo "Codex용 빠른 시작은 CODEX-QUICKSTART.md를 참고하세요."
fi
echo ""
