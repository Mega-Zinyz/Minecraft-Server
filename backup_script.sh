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
REPO_URL="https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}.git"

# Hapus repo lama jika ada, lalu clone ulang untuk memastikan Git aktif
echo "🔄 Menghapus repository lama..."
rm -rf "$REPO_PATH"

echo "🔄 Meng-clone repository..."
if ! git clone "$REPO_URL" "$REPO_PATH"; then
  echo "❌ Gagal meng-clone repository. Periksa koneksi atau izin repository."
  exit 1
fi

# Fungsi untuk menjalankan backup
backup_world() {
    while true; do
        echo "🕒 Memulai backup world..."

        # Masuk ke dalam direktori repo
        cd "$REPO_PATH" || { echo "❌ Gagal masuk ke repository."; exit 1; }

        # Pastikan repository benar-benar valid
        if [ ! -d ".git" ]; then
            echo "❌ Tidak ada folder .git! Clone ulang mungkin gagal."
            exit 1
        fi

        # Copy world ke dalam repo
        echo "📂 Menyalin world data ke repository..."
        rsync -av --delete "$BACKUP_PATH/" "$REPO_PATH/world/"

        # Konfigurasi Git
        git config user.name "Railway Backup Bot"
        git config user.email "backup-bot@railway.app"

        # Cek perubahan dan push
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
