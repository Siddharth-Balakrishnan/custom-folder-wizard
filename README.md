# Custom Folder Wizard for Ubuntu

A native Nautilus (GNOME Files) extension that allows you to right-click and create self-destructing folders, auto-wiping content directories, and password-protected encrypted vaults.

## Features
* **Auto-Delete Folder:** Destroys the folder and everything inside it after a set time.
* **Auto-Delete Contents:** Keeps the folder but automatically trashes files older than a set time.
* **Secure Vaults:** Leverages `gocryptfs` to create AES-256 encrypted directories that can be locked/unlocked via the right-click menu.
* **Custom Wizard:** Mix and match rules, set exact hour limits, and choose between moving to Trash or Permanent Deletion.

## Installation

Run the following command in your terminal to automatically download and install the wizard:

```bash
curl -sSL https://raw.githubusercontent.com/Siddharth-Balakrishnan/custom-folder-wizard/main/install.sh | bash
