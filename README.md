# Git Commands and Aliases

## 📚 Table of Contents

- [Git Commands and Aliases](#git-commands-and-aliases)
  - [📚 Table of Contents](#-table-of-contents)
  - [🧭 Git Commands \& Useful Aliases](#-git-commands--useful-aliases)
    - [🚀 Common Git Commands](#-common-git-commands)
    - [⚙️ Git Aliases (configured globally)](#️-git-aliases-configured-globally)
      - [✅ Usage](#-usage)
    - [📝 Optional Aliases](#-optional-aliases)
      - [Usage](#usage)
    - [⚠️ Notes](#️-notes)
  - [🛠️ AHK2 Executable Build Commands](#️-ahk2-executable-build-commands)
    - [📌 Examples](#-examples)

## 🧭 Git Commands & Useful Aliases

### 🚀 Common Git Commands

```bash
# Clone a repository
git clone https://github.com/your-username/your-repo.git

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

# Commit updates to `README.md` with a timestamp.
git config --global alias.upreadme '!git add README.md && git commit -m "update README.md: $(date +\\\"%Y-%m-%d %H:%M:%S\\\")"'

```

#### ✅ Usage

```bash
git ct     # Commit with timestamp
git aca    # Add all & commit with timestamp
git upreadme
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
---

## 🛠️ AHK2 Executable Build Commands

You can quickly compile your AHK scripts into `.exe` using the `ahk2` alias (which wraps around your custom batch script).  
Format:

```bash
ahk2 [relative-path-to-script.ahk] [relative-path-to-icon.ico]
```

### 📌 Examples

```bash
ahk2 v2/Shortcut\ Generator.ahk icon/internet.ico
ahk2 v2/#ClickTracker.ahk icon/click.ico
ahk2 v2/#KeyModifier.ahk icon/settings.ico
```

**This will:**

- Compile the `.ahk` file to `.exe` in the same base folder.
- Use the specified `.ico` file as the executable icon.
- Automatically place or update a shortcut to the `.exe` on your desktop.
- Terminate any previously running instance of the same `.exe` before launching the new one.
