#!/bin/sh
# ShareXF — Copyright (C) 2026 inukaasith. GPL-3.0, see LICENSE.
# Restarts the Mac app with stats logging and runs the loopback stream check. From mac/: dev/stream-check/run.sh [seconds] [log]
cd "$(dirname "$0")/../.."
LOG=${2:-/tmp/sharexf-stream-check.log}
pkill -f "sharexf/mac/node_modules/electron/dist/Electron.app/Contents/MacOS/Electron \." ; sleep 2
SHAREXF_DEV_PORT=${SHAREXF_DEV_PORT:-47810} SHAREXF_DEBUG_STATS=1 nohup npx electron . > "$LOG" 2>&1 &
sleep 7
SHAREXF_DEV_PORT=${SHAREXF_DEV_PORT:-47810} npx electron dev/stream-check "${1:-20}" 2>&1 | grep '^rx \|^session\|^stream\|error'
echo "--- sender"; grep '\[stream\] {' "$LOG" | tail -3 | cut -c1-260
