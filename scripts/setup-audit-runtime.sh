#!/bin/bash
# 사용법: bash scripts/setup-audit-runtime.sh [runtime-dir]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WEBSTART_HOME="${WEBSTART_HOME:-$HOME/.webstart}"
RUNTIME_DIR="${1:-$REPO_ROOT/audit-runtime}"
VENV_DIR="$WEBSTART_HOME/venvs/audit-runtime"
BIN_DIR="$WEBSTART_HOME/bin"
WRAPPER_PATH="$BIN_DIR/webstart-audit"

if ! command -v python3 &> /dev/null; then
  echo "[오류] python3 가 설치되어 있지 않습니다."
  exit 1
fi

if [ ! -f "$RUNTIME_DIR/pyproject.toml" ]; then
  echo "[오류] audit runtime 을 찾을 수 없습니다: $RUNTIME_DIR"
  exit 1
fi

mkdir -p "$WEBSTART_HOME/venvs" "$BIN_DIR"

python3 -m venv "$VENV_DIR"
"$VENV_DIR/bin/python" -m pip install --upgrade pip setuptools wheel
"$VENV_DIR/bin/python" -m pip install -e "$RUNTIME_DIR"
"$VENV_DIR/bin/python" -m playwright install chromium

cat > "$WRAPPER_PATH" <<EOF
#!/bin/bash
exec "$VENV_DIR/bin/python" -m webstart_audit.cli "\$@"
EOF

chmod +x "$WRAPPER_PATH"

echo "[완료] audit runtime venv 생성: $VENV_DIR"
echo "[완료] 실행 파일 생성: $WRAPPER_PATH"
echo ""
echo "PATH에 $BIN_DIR 이 없으면 아래를 shell profile에 추가하세요:"
echo "  export PATH=\"$BIN_DIR:\$PATH\""
