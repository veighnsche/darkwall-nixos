# TEAM_443: Implement Phase 4 - Add Essential Packages

## Objective
Add wayland packages needed for a usable niri session.

## Plan
1. Add wayland essential packages to kde.nix
2. Add rofi launcher binding to niri-config.nix
3. Test in VM

## Progress
- [x] Add packages to kde.nix
- [x] Add rofi binding to niri config
- [x] Verify build

## Changes Made
1. `modules/desktop/kde.nix`: Added wayland essentials (waybar, rofi, mako, libnotify, swaybg, swaylock, swayidle, wl-clipboard, grim, slurp)
2. `home/vince/niri-config.nix`: Added Mod+D binding for rofi launcher
3. `home/vince/niri-config.nix`: Added spawn-at-startup for waybar and mako

## Notes
- Phase 3 already completed niri config
- krunner doesn't work in niri, need rofi
- `rofi-wayland` has been merged into `rofi` in nixpkgs
- `libnotify` provides `notify-send` command
- Mod+D captured by host VM (Fedora KDE) - can't test in nested VM

## Verification
Run `just vm-test` then:
1. Log into niri → waybar and mako should auto-start
2. Run `notify-send "test"` → notification appears
3. Mod+D for rofi (if not captured by host)

## Additional Work
- Simplified windsurf workflow symlinks (folder instead of individual files)
- Created `/document-for-future-teams` workflow
- Fixed Fedora SELinux blocking nix sandbox - created `nix-sandbox.pp` policy module

## Documentation Added (per /document-for-future-teams)
1. **vm-verify.sh**: Added Phase 4 package verification with ✓/✗ output
2. **README.md**: Added Fedora SELinux setup section
3. **Code comments**: Explained gotchas (rofi-wayland→rofi, libnotify for notify-send)
4. **scripts/fedora/**: SELinux policy files with source (.te) and compiled (.pp)
5. **.plans/fedora-nix-selinux/phase-1.md**: Updated with implementation details
