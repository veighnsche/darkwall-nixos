# Phase 2 — Design (REVISED)

## Issues with Previous Design

1. **Hard copies instead of symlinks** - Requires rebuild on every dotfile change
2. **Missing icon installation API** - Icons are package-specific
3. **Missing desktop entry API** - Desktop entries are package-specific  
4. **Missing env var API** - Some packages need environment variables
5. **Windsurf-specific logic leaked into "generic" installer**

## Proposed Solution

### Package Structure Convention

Every `darkwall-*` package follows this structure:

```
packages/darkwall-<name>/
├── default.nix           # Package derivation (uses mkDarkwallWrapper)
└── dotfiles/             # Files to SYMLINK to user home
    └── ...
```

### Library API

```nix
# lib/mkDarkwallWrapper.nix
{
  # Create a wrapper that symlinks dotfiles on first run
  mkDarkwallWrapper = {
    # Base derivation to wrap
    package,
    
    # Wrapper binary name
    wrapperName,
    
    # Path to wrapped binary (e.g., "bin/windsurf")
    wrappedBin,
    
    # Dotfiles source directory (in the package)
    dotfilesPath,
    
    # Symlink mappings: source (relative to dotfiles) → target (relative to $HOME)
    # Uses SYMLINKS for instant updates during development
    symlinkMap,
    
    # Directories to create before symlinking
    createDirs ? [],
    
    # Environment variables to set
    envVars ? {},
    
    # Extra wrapper args (e.g., LD_LIBRARY_PATH)
    extraWrapperArgs ? [],
  }: ...
}
```

### Key Change: SYMLINKS not COPIES

```bash
# OLD (bad - requires rebuild)
cp "$PKG_DOTFILES/file" "$HOME/.config/file"

# NEW (good - instant updates)
ln -sf "$PKG_DOTFILES/file" "$HOME/.config/file"
```

### Installation Mapping Examples

```nix
# For darkwall-windsurf
installMap = {
  "mcp_config.json" = ".codeium/windsurf/mcp_config.json";
  "global_rules.md" = ".codeium/windsurf/memories/global_rules.md";
  "workflows" = ".codeium/windsurf/global_workflows";  # Directory copy
};

createDirs = [
  ".codeium/windsurf/memories"
  ".codeium/windsurf/global_workflows"
];
```

### Generated Wrapper Script

The library generates a wrapper that:

1. Creates required directories
2. For each mapping:
   - If source is a file: copy-if-newer
   - If source is a directory: copy each file if newer
3. Runs the wrapped program

```bash
# Generated wrapper pseudo-code
DOTFILES="$out/share/<pname>/dotfiles"

# Create directories
mkdir -p "$HOME/.codeium/windsurf/memories"
mkdir -p "$HOME/.codeium/windsurf/global_workflows"

# Install files (copy-if-newer)
for each mapping in installMap:
  src="$DOTFILES/<source>"
  dst="$HOME/<target>"
  if [ ! -f "$dst" ] || [ "$src" -nt "$dst" ]; then
    cp "$src" "$dst"
    echo "<pname>: Installed <source>"
  fi

# Run the actual program
exec <wrapped-program> "$@"
```

---

## Behavioral Decisions

### B1: What happens if target file exists and is newer?

**Decision:** Skip installation, preserve user modifications.

### B2: What happens if source is a directory?

**Decision:** Recursively copy each file using the same copy-if-newer logic.

### B3: What happens on first install vs update?

**Decision:** Same behavior - copy-if-newer handles both cases.

### B4: Should we log every file or just changes?

**Decision:** Only log when files are actually installed/updated.

---

## File Structure After Implementation

```
darkwall-nixos/
├── flake.nix                           # Exports lib.mkDarkwallPackage
├── lib/
│   ├── default.nix                     # Library entry point
│   └── mkDarkwallPackage.nix           # Main function
└── packages/
    └── darkwall-windsurf/
        ├── default.nix                 # Uses mkDarkwallPackage
        └── dotfiles/
            ├── mcp_config.json
            ├── global_rules.md
            └── workflows/
```

---

## Implementation Plan

### Step 1: Create lib/mkDarkwallPackage.nix

Create the library function with:
- Input validation
- Wrapper script generation
- Directory creation logic
- Copy-if-newer logic

### Step 2: Create lib/default.nix

Entry point that exposes `mkDarkwallPackage`.

### Step 3: Update flake.nix

Add `lib` output that exposes the darkwall library.

### Step 4: Refactor darkwall-windsurf

Update to use `mkDarkwallPackage` instead of inline logic.

### Step 5: Test

Verify the package still works correctly.

---

## Open Questions (Resolved)

All questions from Phase 1 resolved with defaults:
- Q1: Simple flat mapping (option A)
- Q2: `lib/` directory (option A)
- Q3: Copy only for now (option A)

---

## Next Steps

Proceed to Phase 3: Implementation
