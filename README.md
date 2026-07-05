# Pi-hole Simple List Backup

This little script connects to your Pi-hole's database, pulls out every blocked domain, and saves them into a clean text file — ready to import back anytime.


## What it does

- Reads every blocked domain from Pi-hole's `gravity.db` database
- Saves them as a plain txt file, one domain per line
- If the file already exists, it just adds the new ones — no duplicates
- If you're not running as root, it'll ask for `sudo` (needed to read Pi-hole's files)
- If `sqlite3`, `git`, or `python3` are missing, it installs them automatically — supports `apt`, `dnf`, `yum`, `pacman`, and `brew`
- Optionally uploads the list to a GitHub repository
- Optionally starts a local HTTP server so you can grab the list from any device on your network
- Available in English and Spanish — pick your language at startup or switch anytime

## Usage

```bash
git clone https://github.com/youruser/pihole_list_backup.git
cd pihole_list_backup
chmod +x pihole_backup.sh
./pihole_backup.sh
```

First, pick your language. Then you'll see a menu like this:

```
  1) Generate backup
  2) Start HTTP server
  3) Upload to GitHub
  4) Change language
  0) Exit
```

### Option 1 — Full backup

This is the main event. It'll:

1. Elevate to `sudo` if needed
2. Check that everything it needs is installed (and install anything missing)
3. Pull all blocked domains from your Pi-hole database
4. Ask where to save the file (just press Enter to use `~/pihole_blocklist.txt`)
5. Write the list — if the file already exists, it merges in only the new stuff
6. Ask if you want to push it to GitHub
7. Ask if you want to serve it over HTTP

### Option 2 — Serve an existing list

Already have a blocklist file? Pick this option, point it to the file, and the script starts a temporary web server. It prints the URL for your local machine and any other devices on your network — handy for copying the list to another Pi-hole or an ad-blocker.

Press `Ctrl+C` to stop the server.

### Option 3 — Upload to GitHub

Select this to push an existing blocklist to a GitHub repo. You'll need:

- Your **GitHub username**
- The **repository name** (like `user/repo` or just `repo`)
- A **personal access token** with `repo` scope (grab one at [GitHub Settings > Developer settings](https://github.com/settings/tokens))
- Your **GitHub email** (for the commit)
- Whether to **clone the repo** fresh or use the current directory

The script clones (if needed), merges the list (no duplicates), commits, and pushes.

## What the output looks like

Just a plain text file — one domain per line. Works with Pi-hole's import tool, uBlock Origin, AdGuard, and pretty much anything that accepts a domain list.

```
example.com
tracker.net
ad.doubleclick.net
```

## Requirements

Just a working Pi-hole installation. The script takes care of the rest.
