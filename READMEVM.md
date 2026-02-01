##  A1. Create and boot a VM from the NixOS ISO


A1.1 Select VM network mode (NAT with port-forward host 2222 → guest 22 or Bridged)
A1.2 Ensure the VM has network connectivity so SSH access to the installer is possible


##  A2. Enter NixOS installer environment, partition disks, and mount filesystems


-A2.1 Run command:
```bash
sudo loadkeys sv-latin1
```
-A2.2 SSH into the NixOS installer from the host terminal
On the VM Console run:
```bash
sudo systemctl start sshd
sudo passwd nixos
ip -4 addr show | grep -Eo 'inet ([0-9]+\.){3}[0-9]+' | awk '{print $2}'
```
On the host terminal run (replace VM_IP with the IP you got):
```bash
ssh nixos@VM_IP
```
If you are using VirtualBox NAT with port-forward (host 2222 → guest 22), use:
```bash
ssh -p 2222 nixos@127.0.0.1
``` 

---

##  B1. Generate NixOS configuration and replace it with TedOS configuration

-B1.1 Generate necessary configs

-B1.2 Copy files for TedOS in folder ted-config from host into VM via scp over SSH

##  B2. Install NixOS and reboot the VM

---
##  C1. Verify boot into TedOS cockpit
