FROM --platform=$TARGETOS/$TARGETARCH ghcr.io/parkervcp/yolks:debian

LABEL author="Torsten Widmann" maintainer="info@goover.de"

ENV DEBIAN_FRONTEND=noninteractive \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_ROOT=/usr/share/dotnet \
    XDG_CONFIG_HOME=/home/container/.config \
    NITROX_CONFIG_PATH=/home/container/.config/Nitrox \
    NITROX_GAME_PATH=/home/container/subnautica \
    ASPNETCORE_ENVIRONMENT=Production

RUN apt update -y \
    && apt upgrade -y \
    && apt install -y \
        wget \
        curl \
        libgdiplus \
        tini \
        libc6-dev \
        libicu-dev \
    && curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel 9.0 --install-dir /usr/share/dotnet \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && echo "export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=0" >> /etc/profile \
    && rm -rf /var/lib/apt/lists/*
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

STOPSIGNAL SIGINT

ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]