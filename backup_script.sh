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
REPO_URL="https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}.git"

# Pastikan /data/world adalah repository Git
cd "$BACKUP_PATH" || { echo "❌ Gagal masuk ke $BACKUP_PATH"; exit 1; }

# Tambahkan safe.directory untuk menghindari error kepemilikan mencurigakan
git config --global --add safe.directory "$BACKUP_PATH"

if [ ! -d ".git" ]; then
    echo "⚠️ Folder /data/world bukan repository Git! Menginisialisasi ulang..."
    git init
    git remote add origin "$REPO_URL"
    git fetch origin main || echo "ℹ️ Repo baru, tidak bisa fetch."
    git reset --hard origin/main || echo "ℹ️ Repo baru, tidak bisa reset ke origin/main."
fi

# 🔥 Set Git Credential Helper agar tidak meminta username/password
git config --global credential.helper store
echo "https://${GITHUB_TOKEN}:x-oauth-basic@github.com" > ~/.git-credentials
chmod 600 ~/.git-credentials

# Fungsi untuk menjalankan backup
backup_world() {
    while true; do
        echo "🕒 Memulai backup world..."

        # Masuk ke dalam direktori world
        cd "$BACKUP_PATH" || { echo "❌ Gagal masuk ke world folder."; exit 1; }

        # Tambahkan semua perubahan ke Git
        git add --all
        git status

        # Konfigurasi Git
        git config user.name "Railway Backup Bot"
        git config user.email "backup-bot@railway.app"

        # Cek perubahan dan pull jika perlu
        echo "🔄 Mengambil perubahan dari remote repository..."
        git pull origin main --rebase || { echo "❌ Gagal mengambil perubahan."; exit 1; }

        # Cek perubahan dan push
        if [ -n "$(git status --porcelain)" ]; then
            echo "📌 Perubahan terdeteksi, melakukan commit..."
            git commit -m "🚀 Automated backup: $(date +'%Y-%m-%d %H:%M:%S')"

            echo "📤 Mengirim backup ke GitHub..."
            if git push origin main; then
                echo "✅ Backup berhasil di-push ke GitHub!"
            else
                echo "❌ Gagal mengirim backup. Periksa koneksi atau izin repository."
                exit 1
            fi
        else
            echo "ℹ️ Tidak ada perubahan di world folder. Backup tidak diperlukan."
        fi

        echo "✅ Proses backup selesai. Menunggu 1 menit sebelum backup berikutnya..."
        sleep 60
    done
}

# Jalankan backup di background
backup_world &

# Mulai server Minecraft
exec /start
