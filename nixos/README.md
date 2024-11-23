# NixOS Configuration

## Scripts

### Rebuild Script

```bash
./nixos-rebuild.sh
```

### Cleanup Script

You can add `--all` flag to remove all generations.

```bash
./nixos-clean.sh
```

## nlap (NixOS Laptop)

> Asus Zephyrus G14 2024

### Boot

- `systemd` for dual-booting NixOS and Windows 11
- Patch new kernel with [linux-g14 v6.11](https://gitlab.com/dragonn/linux-g14/-/tree/6.11), reference: [nixos-on-g14](https://mtoohey.com/articles/nixos-on-g14/)

### Asusctl

- [Supergfxctl and Asusctl on NixOS](https://asus-linux.org/guides/nixos/)
