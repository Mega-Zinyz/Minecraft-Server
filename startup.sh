#!/bin/bash

# Tunggu hingga server Minecraft selesai diunduh dan file-file yang diperlukan ada
echo "Menunggu file server Minecraft selesai diunduh..."

# Ubah port voice chat sesuai konfigurasi
echo "Mengubah port voice chat..."
sed -i 's/^port=.*$/port=25565/' /data/config/voicechat/voicechat-server.properties

# Pastikan file voicechat-server.properties dan konfigurasi lainnya ada
cat /data/config/voicechat/voicechat-server.properties

# Jalankan server Minecraft
echo "Menjalankan server Minecraft..."
exec /start
