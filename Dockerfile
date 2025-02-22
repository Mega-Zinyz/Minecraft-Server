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
    echo "allow-insecure-mode=true" >> /data/config/voicechat-server.properties

# Log isi folder mods untuk debugging
RUN ls -lah /data/mods

# Pastikan permissions benar
RUN chmod 777 /data/mods/*.jar || true

# Konfigurasi server.properties
RUN echo 'enforce-secure-profile=false' >> /data/server.properties && \
    echo 'online-mode=false' >> /data/server.properties && \
    chmod 777 /data/server.properties || true

# Copy dan atur script backup
COPY backup_script.sh /data/scripts/backup_script.sh
RUN chmod +x /data/scripts/backup_script.sh

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
    VERSION=LATEST

RUN mkdir -p /data/config && chown -R 1000:1000 /data/config && chmod -R 777 /data/config

# Jalankan server dengan backup script di background
CMD [ "sh", "-c", "nohup /data/scripts/backup_script.sh & exec /start" ]
