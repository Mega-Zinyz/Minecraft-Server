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
REPO_PATH="/app/repo"  # 👈 Gunakan path yang aman dari volume Railway

# Fungsi untuk menjalankan backup
backup_world() {
    while true; do
        echo "🕒 Memulai backup world..."

        # Hapus history Git lama agar tidak terjadi duplikasi data
        rm -rf "$BACKUP_PATH/.git"

        # Pastikan folder ada sebelum cloning
        rm -rf "$REPO_PATH"
        mkdir -p "$REPO_PATH"

        echo "🔄 Cloning repository..."
        if ! git clone "https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}.git" "$REPO_PATH"; then
          echo "❌ Gagal meng-clone repository. Pastikan token memiliki izin push."
          exit 1
        fi

        # Copy world folder ke dalam repo menggunakan rsync
        echo "📂 Menyalin world data ke repository..."
        rsync -av --delete "$BACKUP_PATH/" "$REPO_PATH/world/"

        # Commit & push jika ada perubahan
        cd "$REPO_PATH" || { echo "❌ Gagal mengakses $REPO_PATH"; exit 1; }
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
