#!/bin/bash
# TEAM_442: VM verification script
# Connects to running VM via SSH and reports system state

set -euo pipefail

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"
SSH_PORT=2222
SSH_USER=vince
SSH_PASS=vince

echo "=== VM Verification Script ==="
echo "Waiting for VM SSH to be available..."

# Wait for SSH to be available (max 60 seconds)
for i in {1..12}; do
    if nc -z localhost $SSH_PORT 2>/dev/null; then
        echo "SSH available!"
        break
    fi
    echo "Waiting... ($i/12)"
    sleep 5
done

if ! nc -z localhost $SSH_PORT 2>/dev/null; then
    echo "ERROR: SSH not available after 60 seconds"
    exit 1
fi

# Use sshpass if available, otherwise prompt
if command -v sshpass &> /dev/null; then
    SSH_CMD="sshpass -p $SSH_PASS ssh $SSH_OPTS -p $SSH_PORT $SSH_USER@localhost"
else
    echo "Note: Install sshpass for automated login, or enter password: $SSH_PASS"
    SSH_CMD="ssh $SSH_OPTS -p $SSH_PORT $SSH_USER@localhost"
fi

echo ""
echo "=== Display Manager Status ==="
$SSH_CMD "systemctl status display-manager --no-pager 2>&1 | head -20" || true

echo ""
echo "=== Available Sessions ==="
$SSH_CMD "ls -la /run/current-system/sw/share/wayland-sessions/ 2>/dev/null || echo 'No wayland sessions'"
$SSH_CMD "ls -la /run/current-system/sw/share/xsessions/ 2>/dev/null || echo 'No xsessions'"

echo ""
echo "=== Niri Status ==="
$SSH_CMD "which niri 2>/dev/null && niri --version || echo 'Niri not installed'"

echo ""
echo "=== Niri Process ==="
$SSH_CMD "pgrep -a niri 2>/dev/null || echo 'Niri not running'"

echo ""
echo "=== Niri Session Check ==="
$SSH_CMD "journalctl --user -u niri --no-pager -n 10 2>/dev/null | grep -E '(listening|Started|ERROR|WARN.*error)' || journalctl -b --no-pager | grep -i niri | grep -E '(listening|Started|ERROR)' | tail -5"

echo ""
echo "=== Current User Session ==="
$SSH_CMD "echo XDG_SESSION_TYPE=\$XDG_SESSION_TYPE; echo XDG_CURRENT_DESKTOP=\$XDG_CURRENT_DESKTOP; echo WAYLAND_DISPLAY=\$WAYLAND_DISPLAY" || true

echo ""
echo "=== TEAM_443: Phase 4 Package Verification ==="
PHASE4_PACKAGES="waybar rofi mako notify-send swaybg swaylock swayidle wl-copy grim slurp"
for pkg in $PHASE4_PACKAGES; do
    if $SSH_CMD "which $pkg" &>/dev/null; then
        echo "✓ $pkg"
    else
        echo "✗ $pkg NOT FOUND"
    fi
done

echo ""
echo "=== Verification Complete ==="
