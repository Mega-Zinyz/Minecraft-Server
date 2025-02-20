# Use itzg/minecraft-server as base image
FROM itzg/minecraft-server

# Install Git for backups
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /data/scripts /data/plugins /data/world

# Copy backup script and set permissions
COPY backup.sh /data/scripts/backup.sh
RUN chmod +x /data/scripts/backup.sh

# Copy SkinsRestorer plugin
COPY plugins/SkinsRestorer.jar /data/plugins/SkinsRestorer.jar
RUN chmod 644 /data/plugins/SkinsRestorer.jar

# Copy world content and set correct permissions
COPY world /data/world
RUN chmod -R 755 /data/world && chown -R 1000:1000 /data/world

# Start backup script in the background and then start Minecraft
CMD [ "sh", "-c", "/data/scripts/backup.sh & /start" ]