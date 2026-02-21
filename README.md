# 🌼 Larrox's PowerShell Scripts

A growing collection of utility PowerShell scripts for Windows — built to fix annoyances, automate tasks, and clean up after badly-behaved software.

---

## 📋 Requirements

- Windows 10 / 11
- PowerShell 5.1 or later
- Some scripts require **Administrator privileges** (noted per script)

> [!TIP]  
> If scripts are blocked, run this **once** in an **Admin PowerShell**:
> ```powershell
> Set-ExecutionPolicy RemoteSigned -Scope LocalMachine
> ```

---

## 📁 Scripts

### `remove_arc_shortcut.ps1`
> 🔧 Requires Administrator

Removes leftover registry entries, shortcuts, and autostart entries from the Arc browser after uninstallation. Arc is known for leaving behind keyboard shortcuts and startup hooks even after being uninstalled.

---

### `geyser_pack_merger.ps1`
Merges Geyser resource packs together. Useful for Minecraft Bedrock/Java crossplay setups using the Geyser plugin.

---

## 🚀 Usage

Right-click any `.ps1` file → **Run with PowerShell**

For scripts requiring admin rights: Right-click → **Run as Administrator**

---

## 📌 Notes

- More scripts will be added over time
- Each script is self-contained and does not require any external dependencies unless noted
- Scripts prompt for confirmation before making any destructive changes

---

## 👤 Contributors

[<img src="https://github.com/larroxtv.png" width="60px;"/><br/><sub><a href="https://github.com/larroxtv">LarroxTv</a></sub>](https://github.com/larroxtv)
