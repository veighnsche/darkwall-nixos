# Phase 4: Testing and Validation - Wayland Desktop Feature

## Test Environment

**Primary:** `just vm-run` (vm-test configuration)
**Secondary:** `just switch` on blep (real hardware, after VM passes)

---

## Test Cases

### TC1: Boot and Auto-Login

**Steps:**
1. Run `just vm-run`
2. Observe boot process

**Expected:**
- greetd starts
- Vince auto-logged into niri (no password prompt)
- Niri compositor visible

**Failure indicators:**
- Black screen
- Login prompt appears (auto-login failed)
- Error messages in boot log

### TC2: Waybar Status Bar

**Steps:**
1. After niri starts, observe top of screen

**Expected:**
- Waybar visible with clock, system stats
- Modules (CPU, memory, network) updating

**Failure indicators:**
- No waybar visible
- Waybar crashes (check `journalctl --user -u waybar`)

### TC3: Application Launcher

**Steps:**
1. Press `Mod+D` (or `Mod+Return`)

**Expected:**
- Rofi launcher appears
- Can search and launch applications

**Failure indicators:**
- Nothing happens
- Rofi appears but crashes

### TC4: Terminal

**Steps:**
1. Press `Mod+T`

**Expected:**
- Kitty terminal opens
- Fastfetch runs (if kitty-startup service works)

**Failure indicators:**
- No terminal opens
- Terminal opens but shell broken

### TC5: Notifications

**Steps:**
1. Run `notify-send "Test" "Hello World"`

**Expected:**
- Mako notification appears in top-right

**Failure indicators:**
- No notification
- Notification appears wrong (styling issues)

### TC6: Screen Lock

**Steps:**
1. Wait for idle timeout (15 min) OR
2. Run `swaylock -f --color 000000`

**Expected:**
- Screen locks
- Can unlock with password

**Failure indicators:**
- Swaylock crashes
- Can't unlock

### TC7: Logout and Session Selection

**Steps:**
1. Press `Mod+Shift+E` to quit niri
2. Observe tuigreet

**Expected:**
- tuigreet login screen appears
- Both "niri" and "Plasma" sessions visible in list
- Can log back in

**Failure indicators:**
- Black screen after logout
- tuigreet not showing sessions
- Sessions list empty

### TC8: KDE Apps in Niri

**Steps:**
1. Launch `dolphin` from rofi
2. Launch `kate` from rofi

**Expected:**
- Apps open correctly
- File dialogs work (GTK portal)
- Apps render properly (Wayland)

**Failure indicators:**
- Apps crash
- Apps look broken (XWayland fallback issues)
- File dialogs don't open

### TC9: XDG Portals (Screen Sharing)

**Steps:**
1. Open Firefox
2. Go to a screen sharing test site (e.g., meet.google.com)
3. Attempt to share screen

**Expected:**
- Portal picker appears
- Can select window/screen to share
- Sharing works

**Failure indicators:**
- No portal picker
- Sharing fails
- Wrong portal used (KDE instead of wlr)

---

## Debugging Commands

```bash
# Check niri status
niri msg version

# Check user services
systemctl --user status waybar swaybg swayidle mako

# Check portal status
busctl --user list | grep portal

# Check greetd logs
journalctl -u greetd

# Check niri logs
journalctl --user -u niri

# List available sessions
ls -la /run/current-system/sw/share/wayland-sessions/
ls -la /run/current-system/sw/share/xsessions/
```

---

## Regression Checklist

After niri works, verify KDE still works:

- [ ] Can log out of niri and log into Plasma
- [ ] Plasma desktop loads correctly
- [ ] KDE apps work in Plasma
- [ ] Screen sharing works in Plasma

---

## Phase 4 Checklist

- [ ] TC1: Boot and auto-login works
- [ ] TC2: Waybar visible and functional
- [ ] TC3: Rofi launcher works
- [ ] TC4: Terminal opens
- [ ] TC5: Notifications work
- [ ] TC6: Screen lock works
- [ ] TC7: Logout/session selection works
- [ ] TC8: KDE apps work in niri
- [ ] TC9: Screen sharing works
- [ ] Regression: KDE Plasma still works

---

## Phase 4 Complete

**Next:** Deploy to blep (real hardware) after VM passes
