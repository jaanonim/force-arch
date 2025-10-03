# Force Arch Linux Installer

Plugin pendrive with this iso and boot form it. Now you have wiped your disk and installed arch linux.

> [!CAUTION]
> This can wipe your data. Use at your own risk.

## Assumptions

For now this script assumes:

- You have UEFI system

It will install on first drive (will prefer nvme drive). If you want to install on other drive quickly pres CTLR-C and run `./install.sh <drive-path>` from this repo.

## Build

Use machine with arch installed or use arch docker container form Dockerfile in privilege mode (not recommended - vm better).
Need to have installed: `archiso` and `just`.
Fetch packages for offline installation.

```
just cache
```

Build the ISO image.

```
just build
```

Every command can be run on remote machine with `just remote <command>`. (look at justfile for details)
