# Pi-hole List Backup

A bash script to export all blocked domains from a Pi-hole instance into a plain-text blocklist, with optional GitHub upload.

## Features

- **Reads from Pi-hole's SQLite database** (`/etc/pihole/gravity.db`) — extracts exact and regex blocked domains
- **Interactive output path** — defaults to `~/pihole_blocklist.txt`
- **Idempotent** — if the output file already exists, new domains are merged in (no duplicates)
- **Auto-elevation** — requests `sudo` automatically if not run as root (required to read Pi-hole's database)
- **Prerequisites check** — verifies `sqlite3` is installed and `gravity.db` exists and is readable
- **Optional GitHub push** — can clone a remote repo or use the local one to commit and push the blocklist
- **Optional local HTTP server** — serves the list via HTTP so you can access it from any device on your network

## Requirements

- Pi-hole (with `gravity.db` at `/etc/pihole/gravity.db`)
- `sqlite3` CLI
- `git` (only needed for GitHub upload)

## Usage

```bash
git clone https://github.com/youruser/pihole_list_backup.git
cd pihole_list_backup
chmod +x pihole_backup.sh
./pihole_backup.sh
```

The script will:

1. Elevate privileges with `sudo` if needed
2. Validate the Pi-hole database
3. Extract all blocked domains
4. Ask where to save the list (press Enter for the default path)
5. Write the list (merging if the file already exists)
6. Ask if you want to push to GitHub (optional)

### GitHub upload

If you choose to upload, you'll be prompted for:

- **GitHub username**
- **Repository** (`user/repo` or just `repo`)
- **Personal access token** (with `repo` scope — create one at [GitHub Settings > Developer settings](https://github.com/settings/tokens))
- **Email** (used for the commit)
- **Clone mode** — either clone the remote repo, or use the current directory as the local repo

The script will then clone/pull, merge the list, commit, and push.

### Local HTTP server

If you choose to start the HTTP server, Python's built-in `http.server` will serve the list file on port `8080` (or the next available port). The script prints:

```
http://localhost:8080/pihole_blocklist.txt
http://192.168.1.10:8080/pihole_blocklist.txt   (from other devices on your network)
```

Press `Ctrl+C` to stop the server.

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
