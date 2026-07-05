# Pi-hole List Backup

A bash script to export all blocked domains from a Pi-hole instance into a plain-text blocklist, with optional GitHub upload.

## Features

- **Reads from Pi-hole's SQLite database** (`/etc/pihole/gravity.db`) — extracts exact and regex blocked domains
- **Interactive output path** — defaults to `~/pihole_blocklist.txt`
- **Idempotent** — if the output file already exists, new domains are merged in (no duplicates)
- **Auto-elevation** — requests `sudo` automatically if not run as root (required to read Pi-hole's database)
- **Auto-install dependencies** — automatically installs `sqlite3`, `git`, and `python3` if missing (supports `apt`, `apt-get`, `dnf`, `yum`, `pacman`, and `brew`)
- **Prerequisites check** — verifies `gravity.db` exists and is readable
- **Optional GitHub push** — can clone a remote repo or use the local one to commit and push the blocklist
- **Optional local HTTP server** — serves the list via HTTP so you can access it from any device on your network

## Requirements

- Pi-hole (with `gravity.db` at `/etc/pihole/gravity.db`)

All other dependencies (`sqlite3`, `git`, `python3`) are installed automatically if missing.

## Usage

```bash
git clone https://github.com/youruser/pihole_list_backup.git
cd pihole_list_backup
chmod +x pihole_backup.sh
./pihole_backup.sh
```

### Menu

When launched, the script asks you to select a language (English or Spanish), then shows an interactive menu:

```
  1) Generate backup
  2) Start HTTP server
  3) Upload to GitHub
  4) Change language
  0) Exit
```

#### Option 1 — Generate backup

1. Elevates privileges with `sudo` if needed
2. Validates the Pi-hole database
3. Extracts all blocked domains
4. Asks where to save the list (press Enter for `~/pihole_blocklist.txt`)
5. Writes the list (merges if the file already exists — no duplicates)
6. Optionally pushes to GitHub
7. Optionally starts a local HTTP server to serve the list

#### Option 2 — Start HTTP server

Asks for an existing blocklist file and serves it via HTTP. Prints access URLs (localhost + LAN IPs) and waits for `Ctrl+C`.

#### Option 3 — Upload to GitHub

Asks for an existing blocklist file, then prompts for:

- **GitHub username**
- **Repository** (`user/repo` or just `repo`)
- **Personal access token** (with `repo` scope — create one at [GitHub Settings > Developer settings](https://github.com/settings/tokens))
- **Email** (used for the commit)
- **Clone mode** — either clone the remote repo, or use the current directory as the local repo

Then clones/pulls, merges the list (deduplicating), commits, and pushes.

## Output format

One domain per line, plain text — compatible with Pi-hole's "Import" feature or any ad-blocker that accepts domain lists.

```
example.com
tracker.net
ad.doubleclick.net
...
```

## License

MIT
