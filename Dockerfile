# Gunakan itzg/minecraft-server sebagai base image
FROM itzg/minecraft-server

# Install Git
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Clone world repository
RUN git clone https://github.com/Mega-Zinyz/Minecraft-World /tmp/world && \
    rm -rf /tmp/world/.git && \
    mkdir -p /data/world && \
    rsync -av /tmp/world/ /data/world/ || echo "World folder is empty, skipping..." && \
    chown -R 1000:1000 /data/world

# Buat folder mods jika belum ada
RUN mkdir -p /data/mods && chown -R 1000:1000 /data/mods

# Copy Simple Voice Chat dan SkinsRestorer ke folder mods
COPY --chown=1000:1000 plugins/skinrestorer-2.2.1+1.21-forge.jar /data/mods/
COPY --chown=1000:1000 plugins/voicechat-forge-1.21.4-2.5.27.jar /data/mods/

# Pastikan voicechat config dibuat dengan benar
RUN mkdir -p /data/config && \
    echo "allow-insecure-mode=true" >> /data/config/voicechat-server.properties && \
    echo "use-experimental-udp-proxy=true" >> /data/config/voicechat-server.properties && \
    echo "udp-proxy-port=25565" >> /data/config/voicechat-server.properties

# Log isi folder mods untuk debugging
RUN ls -lah /data/mods

# Pastikan permissions benar (LEBIH AMAN)
RUN chmod 644 /data/mods/*.jar

# Pastikan server.properties bisa dibaca & ditulis oleh Minecraft server
RUN touch /data/server.properties && chmod 666 /data/server.properties && chown 1000:1000 /data/server.properties

# Pastikan folder data memiliki akses yang benar
RUN chmod -R 755 /data

# Konfigurasi server.properties
RUN echo 'enforce-secure-profile=false' >> /data/server.properties && \
    echo 'online-mode=false' >> /data/server.properties

# Set environment variables untuk server
ENV EULA=TRUE \
    LEVEL_NAME=world \
    MEMORY=4G \
    ONLINE_MODE=false \
    RCON_ENABLED=TRUE \
    SKINS_CONSENT=TRUE \
    SPAWN_LIMIT_MONSTERS=120 \
    TYPE=FORGE \
    USE_MOJANG_API=FALSE \
    VERSION=LATEST \
    SERVER_PORT_UDP=24454

# Copy dan atur script backup
COPY backup_script.sh /data/scripts/backup_script.sh
RUN chmod +x /data/scripts/backup_script.sh

# Jalankan server dengan backup script sebelum memulai Minecraft
CMD ["sh", "-c", "/data/scripts/backup_script.sh & exec /start"]
