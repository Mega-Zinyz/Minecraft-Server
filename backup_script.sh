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

# Masuk ke folder backup
cd "$BACKUP_PATH" || { echo "❌ Gagal mengakses $BACKUP_PATH"; exit 1; }

# Jika .git tidak ada, inisialisasi repository
if [ ! -d ".git" ]; then
  echo "🆕 Menginisialisasi repository di $BACKUP_PATH..."
  git init
  git remote add origin "https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}.git"
fi

# Konfigurasi user Git
git config user.name "Railway Backup Bot"
git config user.email "backup-bot@railway.app"

# Tambahkan dan commit perubahan
git add .
if git diff --cached --quiet; then
  echo "ℹ️ Tidak ada perubahan di world folder. Backup tidak diperlukan."
else
  echo "📌 Perubahan terdeteksi, melakukan commit..."
  git commit -m "🚀 Automated backup: $(date +'%Y-%m-%d %H:%M:%S')"
  
  echo "📤 Mengirim backup ke GitHub..."
  if git push -u origin main; then
    echo "✅ Backup berhasil di-push ke GitHub!"
  else
    echo "❌ Gagal mengirim backup. Periksa koneksi atau izin repository."
    exit 1
  fi
fi

echo "✅ Proses backup selesai. Menunggu 1 menit sebelum backup berikutnya..."
sleep 60
