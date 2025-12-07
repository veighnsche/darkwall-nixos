# TEAM_426: Wayland Desktop (Niri) Installation

## Summary
Installed the wayland-desktop feature from the old nixos repo into darkwall-nixos.

## Architecture Decision
- **greetd + tuigreet** replaces SDDM as display manager
- Both **KDE Plasma** and **Niri** are available as session options
- `--remember-user-session` ensures each user's choice is remembered
- First login: user picks session (one-time)
- Subsequent logins: automatically uses remembered session

## Files Created

### System-level (modules/desktop/)
- `wayland/default.nix` - Niri compositor, packages, XDG portals, env vars
- `greetd.nix` - Display manager with session selection

### User-level (home/vince/)
- `wayland.nix` - Mako, rofi, swaylock, systemd user services
- `wayland/dotfiles/niri/config.kdl` - Niri configuration
- `wayland/dotfiles/waybar/config` - Waybar config
- `wayland/dotfiles/waybar/style.css` - Waybar styling
- `wayland/dotfiles/rofi/config.rasi` - Rofi theme
- `wayland/dotfiles/swaylock/config` - Swaylock theme

### Modified
- `modules/desktop/default.nix` - Added wayland and greetd imports
- `home/vince/default.nix` - Added wayland.nix import

## User Experience
- **Vince**: Selects "niri" at first login → always gets niri
- **Guest**: Selects "plasma" at first login → always gets KDE Plasma
- No dropdown on subsequent logins (session remembered)

## Dependencies
- Requires `programs.niri` from nixpkgs (available in unstable)
- No additional flake inputs needed

## TODO
- [ ] Test build: `just build`
- [ ] Verify niri session appears in tuigreet
- [ ] Test session memory persistence across reboots
