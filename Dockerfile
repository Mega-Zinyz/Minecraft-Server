# Use itzg/minecraft-server as base image
FROM itzg/minecraft-server

# Install Git first
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Clone the GitHub repository (replace with your repository)
RUN git clone https://github.com/Mega-Zinyz/Minecraft-Server /tmp/repo

# Create necessary directories
RUN mkdir -p /data/scripts /data/plugins /data/world

# Copy SkinsRestorer plugin (if available)
COPY --chown=1000:1000 plugins/SkinsRestorer.jar /data/plugins/SkinsRestorer.jar

# Set correct permissions for plugins (give all users access)
RUN test -f /data/plugins/SkinsRestorer.jar && chmod 777 /data/plugins/SkinsRestorer.jar || true

# Copy the world folder (if available)
COPY world /tmp/world
RUN test -d /tmp/world && mv /tmp/world /data/world || echo "World folder not found, skipping..."
RUN chmod -R 777 /data/world || true

# Ensure server.properties is writable by everyone and add the secure profile setting
RUN chmod 777 /data/server.properties || true
RUN echo 'enforce-secure-profile=false' >> /data/server.properties

# Copy the backup script and set proper permissions
COPY backup_script.sh /data/scripts/backup_script.sh
RUN chmod +x /data/scripts/backup_script.sh

# Ensure all directories in /data are accessible by all users
RUN chmod -R 777 /data

# Ensure online-mode is set correctly at runtime
CMD [ "sh", "-c", "nohup /data/scripts/backup_script.sh & exec /start" ]
