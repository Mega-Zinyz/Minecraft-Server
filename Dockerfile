# Use itzg/minecraft-server as the base image
FROM itzg/minecraft-server

# Install Git
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Clone world repository
RUN git clone https://github.com/Mega-Zinyz/Minecraft-World /tmp/world && \
    rm -rf /tmp/world/.git && \
    ls -lah /tmp/world && \
    mkdir -p /data/world && \
    cp -r /tmp/world/* /data/world/ || echo "World folder is empty, skipping..." && \
    chown -R 1000:1000 /data/world  # Ensure correct ownership

# Copy Simple Voice Chat and SkinsRestorer to Forge mods folder
COPY --chown=1000:1000 plugins/skinrestorer-2.2.1+1.21-forge.jar /data/mods/
COPY --chown=1000:1000 plugins/voicechat-forge-1.21.4-2.5.27.jar /data/mods/

# Log contents of mods folder for verification
RUN ls -l /data/mods

# Ensure correct permissions for mods
RUN chmod 777 /data/mods/*.jar || true

# Configure server.properties
RUN echo 'enforce-secure-profile=false' >> /data/server.properties && \
    echo 'online-mode=false' >> /data/server.properties && \
    chmod 777 /data/server.properties || true

# Copy and set up backup script
COPY backup_script.sh /data/scripts/backup_script.sh
RUN chmod +x /data/scripts/backup_script.sh

# Set environment variables for the server
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

# Run server with backup script running in the background
CMD [ "sh", "-c", "nohup /data/scripts/backup_script.sh & exec /start" ]
