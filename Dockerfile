# Gunakan itzg/minecraft-server sebagai base image
FROM itzg/minecraft-server

# Install Git
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Clone repository jika diperlukan
RUN git clone https://github.com/Mega-Zinyz/Minecraft-Server /tmp/repo

# Copy Simple Voice Chat dan SkinsRestorer ke folder mods (karena pakai Forge)
COPY --chown=1000:1000 plugins/skinrestorer-2.2.1+1.21-forge.jar /data/mods/skinrestorer-2.2.1+1.21-forge.jar
COPY --chown=1000:1000 plugins/voicechat.jar /data/mods/voicechat.jar

# Log isi folder mods untuk verifikasi
RUN ls -l /data/mods

# Pastikan file mod memiliki izin yang benar
RUN chmod 777 /data/mods/*.jar || true

# Copy world jika tersedia
COPY world /tmp/world
RUN test -d /tmp/world && mv /tmp/world /data/world || echo "World folder not found, skipping..."
RUN chmod -R 777 /data/world || true

# Konfigurasi server.properties agar online-mode=false dan enforce-secure-profile=false
RUN chmod 777 /data/server.properties || true
RUN echo 'enforce-secure-profile=false' >> /data/server.properties
RUN echo 'online-mode=false' >> /data/server.properties

# Copy backup script dan atur izin eksekusi
COPY backup_script.sh /data/scripts/backup_script.sh
RUN chmod +x /data/scripts/backup_script.sh

# Pastikan semua folder di /data bisa diakses
RUN chmod -R 777 /data

# Pastikan konfigurasi SkinsRestorer diatur dengan benar
RUN if [ -f "/data/mods/skinrestorer-2.2.1+1.21-forge/config.yml" ]; then \
      sed -i '/^commands:/a \ \ perSkinPermissionsConsent: true' /data/mods/skinrestorer-2.2.1+1.21-forge/config.yml; \
    fi

# Environment variables untuk konfigurasi server
ENV EULA=TRUE \
    LEVEL_NAME=world \
    MEMORY=4G \
    ONLINE_MODE=false \
    RCON_ENABLED=TRUE \
    SKINS_CONSENT=TRUE \
    SPAWN_LIMIT_MONSTERS=120 \
    TYPE=FORGE \
    USE_MOJANG_API=FALSE \
    VERSION=LATEST

COPY backup_script.sh /data/scripts/backup_script.sh
RUN chmod +x /data/scripts/backup_script.sh

# Jalankan server dengan backup script berjalan di background
CMD [ "sh", "-c", "nohup /data/scripts/backup_script.sh & exec /start" ]
