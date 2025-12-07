# TEAM_442: Gradual Wayland Desktop Refactor

## Summary
Remove all wayland/niri additions and re-add them incrementally, testing at each step.

## Pain Points
- Big-bang approach caused hard-to-debug failures
- "import-environment deprecated" error blocks VM
- Multiple interacting components make debugging difficult

## Success Criteria
- VM boots to working desktop at each step
- Each addition is tested before next
- Clear understanding of what each component does

## Approach
1. Remove all wayland additions
2. Verify VM works with just KDE
3. Add niri compositor only (minimal)
4. Test VM
5. Add greetd (replace SDDM)
6. Test VM
7. Add user services one by one
8. Test at each step

## Current Files to Remove/Revert
- `modules/desktop/wayland/` (entire directory)
- `modules/desktop/greetd.nix`
- `home/vince/wayland.nix`
- `home/vince/wayland/` (entire directory)
- Changes to `modules/desktop/default.nix`
- Changes to `modules/desktop/kde.nix`
- Changes to `home/vince/default.nix`
