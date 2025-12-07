# Phase 0: Automated VM Verification

## Problem
Currently I have to ask the user what they see in the VM. This is slow and error-prone.

## Solution
Capture VM output automatically so I can verify it myself.

## Methods Available

### 1. QEMU Serial Console Output
Capture boot logs and console output to a file:
```bash
./result/bin/run-vm-test-vm -serial file:vm-console.log
```

### 2. QEMU Screenshot
Take a screenshot of the VM display:
```bash
# In QEMU monitor (Ctrl+Alt+2):
screendump /tmp/vm-screenshot.ppm

# Or via QMP socket:
echo '{"execute": "screendump", "arguments": {"filename": "/tmp/vm-screenshot.png"}}' | nc -U /tmp/qemu-monitor.sock
```

### 3. SSH into VM
If SSH is enabled, run commands inside the VM:
```bash
ssh -o StrictHostKeyChecking=no vince@localhost -p 2222 "systemctl status display-manager"
```

### 4. QEMU Monitor Commands
Use `-monitor stdio` or QMP to query VM state.

## Implementation Plan

### Step 1: Modify just vm-run to capture console
Add to Justfile:
```just
vm-run-debug:
    nix build .#nixosConfigurations.vm-test.config.system.build.vm
    ./result/bin/run-vm-test-vm -serial file:vm-console.log 2>&1 | tee vm-output.log &
    sleep 30
    cat vm-console.log
```

### Step 2: Add SSH port forwarding
Modify VM config to forward SSH port:
```nix
virtualisation.vmVariant.virtualisation.forwardPorts = [
  { from = "host"; host.port = 2222; guest.port = 22; }
];
```

### Step 3: Create verification script
```bash
#!/bin/bash
# scripts/vm-verify.sh
ssh -o StrictHostKeyChecking=no -p 2222 vince@localhost << 'EOF'
echo "=== Display Manager Status ==="
systemctl status display-manager --no-pager
echo "=== Available Sessions ==="
ls -la /run/current-system/sw/share/wayland-sessions/ 2>/dev/null || echo "No wayland sessions"
ls -la /run/current-system/sw/share/xsessions/ 2>/dev/null || echo "No xsessions"
echo "=== Current Session ==="
echo $XDG_SESSION_TYPE
echo $XDG_CURRENT_DESKTOP
EOF
```

## Quick Win: Console Logging

The fastest approach is to capture serial console output. NixOS logs boot messages to serial by default.

### Immediate Implementation

1. Run VM with serial output:
```bash
./result/bin/run-vm-test-vm -serial file:/tmp/vm-boot.log
```

2. After VM boots, read the log:
```bash
cat /tmp/vm-boot.log | tail -100
```

This shows:
- Boot messages
- systemd service status
- Login prompt (if reached)
- Error messages

## Limitations

- **Screenshots**: Require PPM→PNG conversion and image viewing
- **SSH**: Requires VM to fully boot and network to work
- **Serial**: Only shows text, not graphical UI

## Recommendation

For now: Use **serial console logging** for boot verification, **SSH** for post-boot checks.

Later: Add screenshot capability for graphical verification.
