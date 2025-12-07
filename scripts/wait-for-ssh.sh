#!/bin/bash
# TEAM_442: Wait for VM SSH to become available
set -euo pipefail

PORT=2222
TIMEOUT=120

echo "Waiting for SSH on port $PORT (polling every 2s, timeout ${TIMEOUT}s)..."

START=$(date +%s)
while ! nc -z localhost $PORT 2>/dev/null; do
    sleep 2
    ELAPSED=$(($(date +%s) - START))
    echo "  Waiting... (${ELAPSED}s)"
    if [ $ELAPSED -gt $TIMEOUT ]; then
        echo "ERROR: Timeout after ${TIMEOUT}s"
        exit 1
    fi
done

ELAPSED=$(($(date +%s) - START))
echo "SSH available after ${ELAPSED}s"

# Give services a moment to fully start
sleep 5
