FROM --platform=$TARGETOS/$TARGETARCH ghcr.io/parkervcp/yolks:debian

LABEL author="Torsten Widmann" maintainer="info@goover.de"

ENV DEBIAN_FRONTEND=noninteractive \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_ROOT=/usr/share/ \
    ASPNETCORE_URLS=http://*:8080 \
    XDG_CONFIG_HOME=/home/container/.config \
    NITROX_CONFIG_PATH=/home/container/.config/Nitrox

# Install dependencies and .NET 9
RUN apt update -y \
    && apt upgrade -y \
    && apt install -y \
        apt-transport-https \
        wget \
        curl \
        iproute2 \
        libgdiplus \
        tini \
        libc6-dev \
    && wget https://dot.net/v1/dotnet-install.sh \
    && D_V="$(curl -sSL https://dotnet.microsoft.com/en-us/download/dotnet/9.0 | grep -i '<h3 id="sdk-9.*">SDK 9.*.*</h3>' | head -1 | awk -F\" '{print $3}' | awk '{print $2;}' | sed 's/<\/h3>//g')" \
    && chmod +x dotnet-install.sh \
    && ./dotnet-install.sh -i /usr/share -v $D_V \
    && ln -s /usr/share/dotnet /usr/bin/dotnet \
    # Clean up
    && rm -rf /var/lib/apt/lists/* \
    && rm dotnet-install.sh

# Create and switch to container user
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

# Create config directory
RUN mkdir -p ${XDG_CONFIG_HOME}/Nitrox

# Copy Nitrox server files
COPY --chown=container:container ./nitrox /home/container/nitrox/

# Copy entrypoint
COPY --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

STOPSIGNAL SIGINT

ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]