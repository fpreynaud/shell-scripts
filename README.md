# Shell scripts

This repository contains some scripts I like to have available from anywhere

## stdlib.sh

Contains handy functions for bash scripting, such as:
- `min`: get the smallest of 2 numbers
- `max`: get the largest of 2 numbers
- `in_array`: checks if a value is in an array
- `in_map`: checks if a key is present in an associative array
- `argparse`: parse command-line arguments. Inspired by `fish`'s argparse command

## create_smb_share.fish

Setups a SMB share. If Samba is not installed, the script will try to install it.
Requires sudo permissions in order (to install samba, start/restart smbd service, create users, and write to /etc/samba/smb.conf)

### Usage

```
source create_smb_share.fish [-u USER] [-n NAME] PATH
source create_smb_share.fish -h
```

`PATH`: Folder to share. If it does not exist the script will attempt to create it.

Options:
`-u/--user USER`: Associate share with SMB user USER. If USER does not exist it will be created. If this option is not specified it defaults to "smbuser".
`-n/--name NAME`: Specify the name of the SMB share. If not specified, it defaults to "share".

### Limitations

- Does not manage the permissions or ownership on the specified path. This needs to be done manually
- Will append share configuration to /etc/samba/smb.conf without checking if it is already present, so beware of duplicates.
