#!/bin/bash

# Tunggu beberapa detik untuk memastikan file Minecraft sudah ada
echo "Menunggu file server Minecraft selesai diunduh..."
sleep 10  # Tunggu 10 detik

# Ubah port voice chat sesuai konfigurasi jika file ada
if [ -f /data/config/voicechat/voicechat-server.properties ]; then
  echo "Mengubah port voice chat..."
  sed -i 's/^port=.*$/port=25565/' /data/config/voicechat/voicechat-server.properties
  # Pastikan port voice chat telah diubah
  cat /data/config/voicechat/voicechat-server.properties
else
  echo "File voicechat-server.properties tidak ditemukan. Pastikan Minecraft sudah siap."
fi

# Jalankan server Minecraft
echo "Menjalankan server Minecraft..."
exec /start
