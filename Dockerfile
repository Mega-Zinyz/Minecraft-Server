# Use itzg/minecraft-server as base image
FROM itzg/minecraft-server

# Install Git for backups
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /data/scripts /data/plugins /data/world

# Copy backup script and set permissions
COPY backup_script.sh /data/scripts/backup_script.sh
RUN chmod +x /data/scripts/backup_script.sh

# Ensure online-mode is set correctly
RUN echo "enforce-secure-profile=false" >> /data/server.properties

# Check if SkinsRestorer plugin exists before copying
COPY plugins/SkinsRestorer.jar /tmp/SkinsRestorer.jar
RUN test -f /tmp/SkinsRestorer.jar && mv /tmp/SkinsRestorer.jar /data/plugins/SkinsRestorer.jar || echo "SkinsRestorer.jar not found, skipping..."
RUN chmod 755 /data/plugins/SkinsRestorer.jar || true

# Check if the world folder exists before copying
COPY world /tmp/world
RUN test -d /tmp/world && mv /tmp/world /data/world || echo "World folder not found, skipping..."
RUN chmod -R 755 /data/world && chown -R 1000:1000 /data || true

# Start backup script in the background and then start Minecraft
CMD [ "sh", "-c", "nohup /data/scripts/backup_script.sh & exec /start" ]
