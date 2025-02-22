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

# Pastikan folder world ada dan memiliki izin penuh
mkdir -p "$BACKUP_PATH"
chmod -R 777 "$BACKUP_PATH"

# Perbaiki kepemilikan jika diperlukan
chown -R 1000:1000 "$BACKUP_PATH"

# Tandai folder sebagai direktori Git yang aman
git config --global --add safe.directory "$BACKUP_PATH"

# Fungsi untuk menjalankan backup
backup_world() {
    while true; do
        echo "🕒 Memulai backup world..."

        cd "$BACKUP_PATH" || { echo "❌ Gagal mengakses $BACKUP_PATH"; exit 1; }

        # Jika folder belum merupakan Git repository, inisialisasi
        if [ ! -d ".git" ]; then
          echo "🔄 Repository belum ada, menginisialisasi Git..."
          git init
          git remote add origin "$REPO_URL"
          git fetch origin

          # Paksa branch default menjadi `main`
          git checkout -b main || git checkout main
          git branch --set-upstream-to=origin/main main
          git pull origin main || echo "⚠️ Tidak dapat menarik perubahan, mungkin branch kosong."
        else
          echo "🔄 Repository sudah ada, melakukan pull dari origin..."

          # Abort jika ada rebase yang gagal
          git rebase --abort 2>/dev/null || true

          # Reset ke versi terbaru dari origin/main untuk menghindari konflik
          git fetch origin
          git reset --hard origin/main
          
          git pull --rebase origin main || echo "⚠️ Gagal melakukan rebase, mungkin branch kosong."
        fi

        # Commit & push jika ada perubahan
        git config user.name "Railway Backup Bot"
        git config user.email "backup-bot@railway.app"

        if [ -n "$(git status --porcelain)" ]; then
          echo "📌 Perubahan terdeteksi, melakukan commit..."
          git add .
          git commit -m "🚀 Automated backup: $(date +'%Y-%m-%d %H:%M:%S')"

          echo "📤 Mengirim backup ke GitHub..."
          if git push origin main; then
            echo "✅ Backup berhasil di-push ke GitHub!"
          else
            echo "❌ Gagal mengirim backup. Melakukan force push..."
            git pull --rebase origin main
            git push --force origin main && echo "✅ Backup berhasil di-push dengan force push!"
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
