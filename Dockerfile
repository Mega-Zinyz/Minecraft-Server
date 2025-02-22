# Use itzg/minecraft-server as base image
FROM itzg/minecraft-server

# Install Git and Rsync
RUN apt-get update && apt-get install -y git rsync && rm -rf /var/lib/apt/lists/*

# Clone world repository
RUN git clone https://github.com/Mega-Zinyz/Minecraft-World /tmp/world && \
    mkdir -p /data/world && \
    if [ -n "$(ls -A /tmp/world)" ]; then rsync -av /tmp/world/ /data/world/; fi && \
    chown -R 1000:1000 /data/world && \
    chmod -R 777 /data/world  # 🔥 Giving full access to world folder

# Create mods folder if it doesn't exist
RUN mkdir -p /data/mods /data/config /data/scripts
RUN chown -R 1000:1000 /data

# Copy all mods files to server's mods folder
COPY --chown=1000:1000 mods/ /data/mods/
RUN chmod -R 777 /data/world/serverconfig && chown -R 1000:1000 /data/world/serverconfig
RUN mkdir -p /data/world/serverconfig && chown -R 1000:1000 /data/world

# Ensure permissions are correct
RUN find /data/mods -type f -name "*.jar" -exec chmod 644 {} \;

# **Fix Permissions for server.properties**
RUN touch /data/server.properties && chmod 666 /data/server.properties && chown 1000:1000 /data/server.properties
RUN ls -lah /data/server.properties  # Debugging

RUN chmod -R 755 /data/config
RUN chown -R 1000:1000 /data/config

# Ensure the voicechat-server.properties and translations.properties exist and are writable
RUN mkdir -p /data/config/voicechat && \
    touch /data/config/voicechat/voicechat-server.properties /data/config/voicechat/translations.properties && \
    chmod 777 /data/config/voicechat/voicechat-server.properties && \
    chmod 777 /data/config/voicechat/translations.properties && \
    chown 1000:1000 /data/config/voicechat/voicechat-server.properties /data/config/voicechat/translations.properties

# Configure voicechat
RUN echo "allow-insecure-mode=true" > /data/config/voicechat/voicechat-server.properties && \
    echo "use-experimental-udp-proxy=true" >> /data/config/voicechat/voicechat-server.properties && \
    echo "udp-proxy-port=25565" >> /data/config/voicechat/voicechat-server.properties

# Configure server.properties
RUN echo 'enforce-secure-profile=false' >> /data/server.properties && \
    echo 'online-mode=false' >> /data/server.properties

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
    VERSION=LATEST \
    SERVER_PORT_UDP=25565

# Copy backup script and give execute permissions
COPY backup_script.sh /data/scripts/backup_script.sh
RUN chmod +x /data/scripts/backup_script.sh
RUN chown 1000:1000 /data/scripts/backup_script.sh

# **Fix backup issue - Prevent looping**
ENTRYPOINT ["/bin/sh", "-c", "/data/scripts/backup_script.sh && exec /start"]
