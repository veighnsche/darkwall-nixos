# Phase 3: Add Niri Config File

## Goal
Add a minimal niri config file - just enough to be usable.

## Changes

### Step 1: Create minimal niri config
Create `home/vince/niri-config.nix`:

```nix
{ config, pkgs, ... }:
{
  xdg.configFile."niri/config.kdl".text = ''
    // Minimal niri config - TEAM_442
    
    input {
      keyboard {
        xkb { }
      }
    }
    
    binds {
      Mod+Return { spawn "konsole"; }
      Mod+D { spawn "krunner"; }
      Mod+Q { close-window; }
      Mod+Shift+E { quit; }
      
      Mod+Left { focus-column-left; }
      Mod+Right { focus-column-right; }
      Mod+Up { focus-workspace-up; }
      Mod+Down { focus-workspace-down; }
    }
  '';
}
```

### Step 2: Import in home/vince/default.nix
```nix
imports = [
  ...
  ./niri-config.nix
];
```

## Verification
```bash
git add -A && just vm-run
```

1. Log into niri from SDDM
2. Press Mod+Return → konsole opens
3. Press Mod+Shift+E → exits niri

## Exit Criteria
- [ ] Minimal config created
- [ ] Can open terminal in niri
- [ ] Can exit niri cleanly
