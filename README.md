# Spark WordPress — Docker Setup

## What this does automatically
When you run `docker compose up -d`:
- ✅ MySQL database is created
- ✅ WordPress is installed and configured
- ✅ Site URL is set to http://spark.wp.com:8088
- ✅ Admin account is created
- ✅ FTP server is ready for file upload/download
- ✅ phpMyAdmin is ready

No manual steps. No installation screen.

---

## First time setup (do this once)

### Step 1 — Add to hosts file
**Windows** — Open Notepad as Administrator → open:
`C:\Windows\System32\drivers\etc\hosts`
Add this line at the bottom:
```
127.0.0.1    spark.wp.com
```

**Mac/Linux** — Run in terminal:
```
sudo echo "127.0.0.1 spark.wp.com" >> /etc/hosts
```

### Step 2 — Create your .env file
```
copy .env.example .env
```

### Step 3 — Start everything
```
docker compose up -d
```

Wait about 30 seconds for auto-setup to complete, then open:

---

## URLs
| Service | URL |
|---|---|
| WordPress Site | http://spark.wp.com:8088 |
| WordPress Admin | http://spark.wp.com:8088/wp-admin |
| phpMyAdmin | http://localhost:8082 |

---

## FTP Access (FileZilla)
| Setting | Value |
|---|---|
| Host | localhost |
| Port | 21 |
| Username | wpuser (from .env FTP_USER) |
| Password | ftp@123 (from .env FTP_PASS) |
| Protocol | FTP |

---

## Admin Login
| Setting | Value |
|---|---|
| URL | http://spark.wp.com:8088/wp-admin |
| Username | admin (from .env WP_ADMIN_USER) |
| Password | admin@123 (from .env WP_ADMIN_PASSWORD) |

---

## Database Sync (for teams)
When you make database changes (in wp-admin):
1. Export from phpMyAdmin → save as `database/latest.sql`
2. `git add . && git commit -m "update db" && git push`

When teammate pushes database changes:
1. `git pull`
2. Import `database/latest.sql` in phpMyAdmin

**Rule: Touched wp-admin? Export DB before pushing.**

---

## Useful Commands
| Command | What it does |
|---|---|
| `docker compose up -d` | Start everything |
| `docker compose down` | Stop everything |
| `docker compose down -v` | Stop + delete database (fresh start) |
| `docker compose logs wpcli` | See auto-setup logs |
| `docker compose ps` | Check container status |
