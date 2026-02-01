##  A1. Create and boot a VM from the NixOS ISO


-A1.1 Configure VM networking (NAT with port-forward or Bridged)
-A1.2 Enable SSH access to the installer (network available)


##  A2. Enter NixOS installer environment, partition disks, and mount filesystems


-A2.1 Run command:
```bash
sudo loadkeys sv-latin1
```
-A2.2 SSH into the NixOS installer from the host terminal

---

##  B1. Generate NixOS configuration and replace it with TedOS configuration

-B1.1 Generate necessary configs

-B1.2 Copy files for TedOS in folder ted-config from host into VM via scp over SSH

##  B2. Install NixOS and reboot the VM

---
##  C1. Verify boot into TedOS cockpit
