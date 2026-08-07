#!/bin/bash
set -e

echo "=== Harness Initialization (dcnet/cam) ==="

# Monorepo 2 app Python độc lập, không có test suite (xem CLAUDE.md).
# Verify = syntax check cả 2 app; verify hành vi thì chạy app thật.
PY="$(command -v python3 || command -v python)"

echo "=== Syntax check: simple_ai_vision ==="
"$PY" -m compileall -q simple_ai_vision

echo "=== Syntax check: fall_detection_web ==="
"$PY" -m compileall -q -x '(^|/)(\.?venv|env|__pycache__)(/|$)' fall_detection_web

echo "=== Verification Complete ==="
echo ""
echo "Next steps:"
echo "1. Đọc feature_list.json — feature đang active"
echo "2. Đọc progress.md + knowledge/index.md"
echo "3. Làm đúng 1 feature; verify lại trước khi khai done"
