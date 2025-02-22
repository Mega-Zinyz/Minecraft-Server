#!/bin/bash

# Update the voice chat port to 25565
sed -i 's/^port=.*/port=25565/' /data/config/voicechat/voicechat-server.properties

# Echo the updated port
echo "Voice chat will use port 25565"

# Start the Minecraft server
exec /start