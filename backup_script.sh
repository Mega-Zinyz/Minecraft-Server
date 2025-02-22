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
BACKUP_PATH="/data/world"  # Langsung gunakan world sebagai repo
REPO_URL="https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}.git"

# Pastikan folder world memiliki izin penuh
chmod -R 777 "$BACKUP_PATH"

# Fungsi untuk menjalankan backup
backup_world() {
    while true; do
        echo "🕒 Memulai backup world..."

        # Pastikan folder ada sebelum cloning
        if [ ! -d "$BACKUP_PATH/.git" ]; then
          echo "🔄 Repository belum ada, meng-clone..."
          rm -rf "$BACKUP_PATH"
          git clone "$REPO_URL" "$BACKUP_PATH"
        fi

        cd "$BACKUP_PATH" || { echo "❌ Gagal mengakses $BACKUP_PATH"; exit 1; }

        # Pastikan branch menggunakan 'main'
        git branch -M main
        git pull origin main

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
