#!/bin/bash
cd /home/container

# Ensure config directory exists
mkdir -p ${XDG_CONFIG_HOME}/Nitrox

# Set environment variables
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP
export DOTNET_ROOT=/usr/share/

# Print dotnet version
printf "\033[1m\033[33mcontainer@pelican~ \033[0mdotnet --version\n"
dotnet --version

# Default startup command
DEFAULT_STARTUP="dotnet ./nitrox/NitroxServer-Subnautica.dll"
STARTUP=${STARTUP:-$DEFAULT_STARTUP}

# Variable substitution
MODIFIED_STARTUP=$(eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g'))
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# Run the server
exec ${MODIFIED_STARTUP}