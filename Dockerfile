# Gunakan itzg/minecraft-server sebagai base image
FROM itzg/minecraft-server

# Install Git dan Rsync
RUN apt-get update && apt-get install -y git rsync && rm -rf /var/lib/apt/lists/*

# Clone world repository
RUN git clone https://github.com/Mega-Zinyz/Minecraft-World /tmp/world && \
    rm -rf /tmp/world/.git && \
    mkdir -p /data/world && \
    if [ -n "$(ls -A /tmp/world)" ]; then rsync -av /tmp/world/ /data/world/; fi && \
    chown -R 1000:1000 /data/world

# Buat folder mods jika belum ada
RUN mkdir -p /data/mods /data/config /data/scripts
RUN chown -R 1000:1000 /data

# Copy mods
COPY --chown=1000:1000 plugins/skinrestorer-2.2.1+1.21-forge.jar /data/mods/
COPY --chown=1000:1000 plugins/voicechat-forge-1.21.4-2.5.27.jar /data/mods/

# Pastikan permissions benar
RUN find /data/mods -type f -name "*.jar" -exec chmod 644 {} \;
RUN chmod 644 /data/server.properties
RUN chmod -R 755 /data/config
RUN chown -R 1000:1000 /data/config

# Konfigurasi voicechat
RUN echo "allow-insecure-mode=true" > /data/config/voicechat-server.properties && \
    echo "use-experimental-udp-proxy=true" >> /data/config/voicechat-server.properties && \
    echo "udp-proxy-port=24454" >> /data/config/voicechat-server.properties

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

# Copy backup script dan berikan izin eksekusi
COPY backup_script.sh /data/scripts/backup_script.sh
RUN chmod +x /data/scripts/backup_script.sh

# Debugging: Cek isi folder sebelum start
RUN ls -lah /data/mods /data/config /data/

# Jalankan backup script sebelum server
ENTRYPOINT ["/bin/sh", "-c", "/data/scripts/backup_script.sh & exec /start"]
