FROM --platform=$TARGETOS/$TARGETARCH ghcr.io/parkervcp/yolks:debian

LABEL author="Torsten Widmann" maintainer="info@goover.de"

ENV DEBIAN_FRONTEND=noninteractive \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_ROOT=/usr/share/ \
    XDG_CONFIG_HOME=/home/container/.config \
    NITROX_CONFIG_PATH=/home/container/.config/Nitrox

RUN apt update -y \
    && apt upgrade -y \
    && apt install -y \
        wget \
        curl \
        libgdiplus \
        tini \
    && wget https://dot.net/v1/dotnet-install.sh \
    && chmod +x dotnet-install.sh \
    && ./dotnet-install.sh -i /usr/share -v 9.0 \
    && ln -s /usr/share/dotnet /usr/bin/dotnet \
    && rm -rf /var/lib/apt/lists/* \
    && rm dotnet-install.sh

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container
RUN mkdir -p ${XDG_CONFIG_HOME}/Nitrox

COPY --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]