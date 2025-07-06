# Git Commands and Aliases

## 🧭 Git Commands & Useful Aliases

### 🚀 Common Git Commands

```bash
# Clone a repository
git clone https://github.com/jackboom2510/AutoHotkey

# Stage all changes
git add .

# Commit with message
git commit -m "Your message"

# Push to remote
git push origin main

# Pull latest changes
git pull origin main

# Check status
git status

# View commit history (pretty)
git log --oneline --graph --decorate --all
```

---

### ⚙️ Git Aliases (configured globally)

```bash
# Commit with timestamp
git config --global alias.ct '!git commit -m "$(date +"auto commit: %Y-%m-%d %H:%M:%S")"'

# Add all + commit with timestamp
git config --global alias.aca '!git add . && git commit -m "$(date +"auto commit: %Y-%m-%d %H:%M:%S")"'
```

#### ✅ Usage

```bash
git ct     # Commit with timestamp
git aca    # Add all & commit with timestamp
```

---

### 📝 Optional Aliases

```bash
# Show git status
git config --global alias.st "status"

# Pretty git log
git config --global alias.lg "log --oneline --graph --decorate --all"
```

#### Usage

```bash
git st     # Show status
git lg     # Show pretty commit history
```

---

### ⚠️ Notes

- These aliases use `date` — they require Git Bash, WSL, or Linux/macOS terminal.
- They **won’t work** in plain Windows CMD or PowerShell unless you install Unix tools.
- Ideal for solo workflows or quick local commits.

---
