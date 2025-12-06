# TEAM_431: Investigate VM Virtualisation Options Bug

## Team Registration
- **Team ID**: TEAM_431
- **Bug Summary**: virtualisation.cores option does not exist
- **Start Date**: 2025-12-06
- **Status**: Investigating

## Bug Report

### Error Message
```
error: The option `virtualisation.cores' does not exist. Definition values:
- In `/nix/store/1n288d1mnh43ii03dgp6fcsbhrs47ia1-source/hosts/vm-test': 8
```

### Reproduction Steps
1. Added virtualisation configuration to vm-test/default.nix
2. Ran `just vm-run`
3. Error occurred during nix build

### Expected vs Actual
- **Expected**: VM builds with 8 cores, 16GB RAM, 50GB disk
- **Actual**: Build fails with "virtualisation.cores does not exist"

## Investigation Progress

### Phase 1: Understand the Symptom
- [x] Gathered bug report
- [x] Confirmed reproducibility
- [x] Locate correct VM configuration options

### Phase 2: Form Hypotheses
- [x] Brainstorm possible causes
- [x] Prioritize hypotheses

### Phase 3: Test Hypotheses
- [x] Investigate NixOS VM options
- [x] Check documentation

### Phase 4: Root Cause Analysis
- [x] Identify correct option names
- [x] Verify solution

### Phase 5: Decision
- [x] Fixed immediately (simple configuration change)

## Root Cause Analysis

### Primary Issue: Incorrect VM Configuration Namespace
- **Problem**: Used `virtualisation.cores` which doesn't exist
- **Solution**: Use `virtualisation.vmVariant.virtualisation.cores`

### Secondary Issue: Incorrect Data Types
- **Problem**: Used string values like "16G" and "50G" 
- **Solution**: Use integer values in MB (16 * 1024, 50 * 1024)

### Tertiary Issue: Import Path Mismatch
- **Problem**: Import paths referenced non-existent `./windsurf` directory
- **Solution**: Updated to `./darkwall-windsurf` directory

## Resolution Applied

```nix
# VM resource configuration
virtualisation.vmVariant.virtualisation = {
  cores = 8;
  memorySize = 16 * 1024;  # 16GB in MB
  diskSize = 50 * 1024;    # 50GB in MB
};
```

## Verification
- `nix build --dry-run` passes ✅
- `just vm-run` successfully builds and starts VM ✅
- VM now has 8 cores, 16GB RAM, 50GB disk ✅
