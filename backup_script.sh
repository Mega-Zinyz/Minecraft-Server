#!/bin/sh

# Pastikan Railway Environment Variables sudah diatur
if [ -z "$RAILWAY_GITHUB_USER" ] || [ -z "$RAILWAY_GITHUB_REPO" ] || [ -z "$RAILWAY_GITHUB_TOKEN" ]; then
  echo "❌ Error: Railway GitHub environment variables tidak diatur."
  exit 1
fi

# Konfigurasi variabel
GITHUB_USER="$RAILWAY_GITHUB_USER"
GITHUB_REPO="$RAILWAY_GITHUB_REPO"
GITHUB_TOKEN="$RAILWAY_GITHUB_TOKEN"
BACKUP_PATH="/data/world"
REPO_PATH="/tmp/repo"

# Hapus git history lama dari world (hindari commit file besar berkali-kali)
rm -rf "$BACKUP_PATH/.git"

# Hapus clone repo lama, lalu clone lagi
rm -rf "$REPO_PATH"
git clone https://"$GITHUB_TOKEN"@github.com/"$GITHUB_USER"/"$GITHUB_REPO".git "$REPO_PATH"

# Copy world folder ke dalam repo menggunakan rsync (lebih efisien)
rsync -av --delete "$BACKUP_PATH/" "$REPO_PATH/world/"

# Commit & push jika ada perubahan
cd "$REPO_PATH" || exit
git config user.name "Railway Backup Bot"
git config user.email "backup-bot@railway.app"

if [ -n "$(git status --porcelain)" ]; then
  git add .
  git commit -m "🚀 Automated backup: $(date +'%Y-%m-%d %H:%M:%S')"
  git push origin main
  echo "✅ Backup berhasil di-push ke GitHub."
else
  echo "ℹ️ Tidak ada perubahan di world folder. Backup tidak diperlukan."
fi
