# Machine Identifier Reset Scripts

This repository contains a set of shell scripts designed to change core machine identifiers on a Linux (Ubuntu/Debian-based) system. The primary purpose is to make a specific application treat the computer as a new, unrecognized device.

---

## ☢️ Caution: Run These Scripts at Your Own Risk

**These scripts make significant changes to your system's configuration.**

* **Potential for Data Loss:** The `clean_yourapp.sh` script uses `rm -rf`, which will **permanently delete files and directories without confirmation**. Double-check the paths in the script before running.
* **Temporary Network Disconnection:** Changing your MAC address will briefly disconnect your network interface.
* **Administrator Privileges Required:** These scripts require `sudo` (root) to run, as they modify protected system files.

It is highly recommended to understand what each command does before executing the scripts. Backups of your original MAC address and `machine-id` are created by these scripts where possible, but improper use can still lead to serious issues. Test in a disposable VM first.

---

## Scripts

This project includes three independent scripts:

1. **`change_mac_address.sh`**

   * Lists your network interfaces.
   * Asks you to select one.
   * Saves your current MAC address to `~/orig_mac.txt`.
   * Assigns a new, random MAC address to the selected interface.

2. **`reset_machine_id.sh`**

   * Displays your current machine-id.
   * Saves a backup to `/etc/machine-id.bak`.
   * Erases the current ID and generates a new one via systemd tools.

3. **`clean_yourapp.sh`**

   * Stops all processes related to "Yourapp".
   * Permanently deletes common configuration and cache directories for "Yourapp".

---

## How to Use (Linux)

1. **Clone the repository (optional):**

   ```bash
   git clone <repository-url>
   cd machine_identifier_reset
   ```

2. **Make the scripts executable:** (only required once)

   ```bash
   chmod +x *.sh
   ```

3. **Run the desired script:** Run each script individually as needed.

   *To change your MAC address:*

   ```bash
   ./change_mac_address.sh
   ```

   *To reset your machine-id (requires sudo):*

   ```bash
   sudo ./reset_machine_id.sh
   ```

   *To clean application data:*

   ```bash
   ./clean_yourapp.sh
   ```

---

## Platform notes & equivalents (macOS & Windows)

> **Short summary:** The scripts in this repo are written for Linux (systemd/Ubuntu/Debian) and will **not** work unmodified on macOS or Windows. Below are safer alternatives, equivalent commands, and important platform-specific caveats. **Do not** run destructive operations on production machines.

### macOS (Catalina and later — e.g. Big Sur, Monterey, Ventura)

* **Shell & tools:** macOS uses **zsh** as the default interactive shell since Catalina. `/bin/bash` is still present but is typically an older version supplied by Apple. macOS does **not** use `systemd` and does not have `/etc/machine-id`. Many Linux utilities (e.g., `ip`, `macchanger`) are not bundled by default — install extra tooling with Homebrew (`brew`) if needed.

* **List network interfaces:**

  ```bash
  ifconfig -a
  # or
  networksetup -listallhardwareports
  ```

* **Read current MAC address (example):**

  ```bash
  ifconfig en0 | awk '/ether/ {print $2}'  # replace en0 with the actual device
  ```

* **Change MAC address (transient, may not work on all hardware):**

  ```bash
  sudo ifconfig <iface> down
  sudo ifconfig <iface> ether 02:11:22:33:44:55
  sudo ifconfig <iface> up
  ```

  *Notes:*

  * This change is usually transient (it often reverts after interface reset or reboot).
  * Modern macOS versions and certain drivers may not permit changing the MAC. Use caution and test on non-critical hardware.
  * There is no official Apple `macchanger`; community ports or manual `ifconfig` are the common approaches.

* **Machine identifier:** macOS does not use `/etc/machine-id` or `systemd-machine-id-setup`. A common read-only identifier on macOS is the IOPlatformUUID:

  ```bash
  ioreg -rd1 -c IOPlatformExpertDevice | awk -F\" '/IOPlatformUUID/{print $(NF-1)}'
  ```

  **Do not attempt to change this identifier** on normal systems — modifying low-level hardware or system identifiers on macOS is unsupported and can break system services, iCloud, and licensing.

* **Stopping an app & removing app data:**

  ```bash
  pkill -f "Yourapp" || true

  rm -rf ~/Library/Application\ Support/Yourapp
  rm -rf ~/Library/Caches/Yourapp
  rm -rf ~/Library/Preferences/com.yourapp.*
  ```

  macOS stores user app data under `~/Library`; paths differ from Linux's `~/.config`/`~/.local`.

---

### Windows (Windows 10 / 11)

* **General:** Windows uses different management tools (PowerShell is recommended). You can run the Linux scripts inside WSL (Windows Subsystem for Linux), but WSL **only** affects the Linux environment — it cannot change host-level hardware identifiers (e.g., Windows NIC MAC, Windows Machine GUID).

* **Sudo on Windows (clarified):** Microsoft has introduced a *Sudo for Windows* wrapper in recent Windows 11 builds that provides a `sudo`-style experience and integrates with UAC (Settings → System → For developers → "Enable sudo"). Availability depends on OS build/channel and whether it is enabled; it is not identical to the Linux `sudo` binary. If `sudo` isn’t available, use **Run as administrator**, PowerShell `Start-Process -Verb RunAs`, or a third-party utility such as `gsudo`.

* **List network adapters (PowerShell):**

  ```powershell
  Get-NetAdapter
  ```

* **Read MAC address (PowerShell):**

  ```powershell
  Get-NetAdapter -Name "Ethernet" | Select-Object -ExpandProperty MacAddress
  ```

* **Change MAC address (driver support required):**

  ```powershell
  # Only works if the driver exposes the setting
  Set-NetAdapterAdvancedProperty -Name "Ethernet" -DisplayName "Network Address" -DisplayValue "001122334455"

  Disable-NetAdapter -Name "Ethernet" -Confirm:$false
  Enable-NetAdapter -Name "Ethernet"
  ```

  *Notes:*

  * Not all NIC drivers honor the "Network Address" property. If unsupported, use Device Manager → Properties → Advanced → "Network Address".
  * Changes must be made on the Windows host — they cannot be applied from inside WSL.

* **Machine identifier (MachineGuid):**

  * Read with PowerShell:

  ```powershell
  Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Cryptography' -Name MachineGuid
  ```

  **Strong caution:** `MachineGuid` is created by Windows and used by Windows and third-party software for machine-level identification. Modifying it can cause issues with activation, licensing, domain membership, or other software that relies on it. Test only in disposable VMs.

* **Stopping an app & removing app data (PowerShell):**

  ```powershell
  Stop-Process -Name "Yourapp" -Force -ErrorAction SilentlyContinue

  Remove-Item -Recurse -Force "$env:APPDATA\\Yourapp" -ErrorAction SilentlyContinue
  Remove-Item -Recurse -Force "$env:LOCALAPPDATA\\Yourapp" -ErrorAction SilentlyContinue
  ```

---

## WSL (Windows Subsystem for Linux) notes

* Running the Linux scripts inside WSL affects only the WSL filesystem and environment. WSL **cannot** modify Windows host hardware settings (for example, the host NIC MAC or MachineGuid).
* WSL is useful as a safe testing environment for Linux-only behaviors. For host-level changes, use native host tools with appropriate elevation.

---

## Safe testing & backups (recommended)

Before doing anything destructive, follow these steps:

1. **Dry run first:** Add a flag or change scripts to print commands instead of executing them (no `rm`, no `truncate`, no `ip link set ... down`).
2. **Create backups explicitly:**

   ```bash
   # Linux example
   cp -a /etc/machine-id /etc/machine-id.bak
   ip link show <iface> | awk '/ether/ {print $2}' > ~/orig_mac.txt
   ```

   ```bash
   # macOS example
   ifconfig <iface> | awk '/ether/ {print $2}' > ~/orig_mac.txt
   ```

   ```powershell
   # Windows example (PowerShell)
   Get-ItemProperty -Path 'HKLM:\\SOFTWARE\\Microsoft\\Cryptography' -Name MachineGuid | Out-File C:\\Users\\$env:USERNAME\\machineguid.txt
   ```
3. **Verify backups exist before destructive steps:**

   ```bash
   if [ ! -s /etc/machine-id.bak ]; then
     echo "Backup /etc/machine-id.bak not found — aborting."
     exit 1
   fi
   ```
4. **Fail early and require explicit confirmation for destructive actions:**

   ```bash
   set -euo pipefail

   confirm() {
     read -rp "$1 [y/N]: " ans
     case "$ans" in [Yy]*) return 0;; *) return 1;; esac
   }

   confirm "Are you sure you want to delete these paths? THIS IS DESTRUCTIVE" || exit 1
   ```
5. **Test in a VM or disposable environment** with snapshots so you can rollback.
6. **Have recovery options** (bootable rescue media, recovery console, or remote KVM access) before making system-level changes.

---

## Legal & policy note

Altering hardware identifiers, MAC addresses, or machine GUIDs may violate network policies, software terms of service, or local law in some jurisdictions (for example, if done to evade access controls or licensing). Use these scripts only on machines you own or have explicit permission to modify.

---

## Contribution

If you want macOS- or Windows-specific helper scripts added to this repo (non-destructive helpers that only read and backup values), open an issue or submit a pull request. I can create `macos_helpers.sh` and `windows_helpers.ps1` that perform safe reads/backups and include clear warnings for destructive operations.

---

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
