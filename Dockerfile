FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    git \
    python3 \
    python3-numpy \
    python3-xdg \
    net-tools \
    x11vnc \
    xvfb \
    dbus-x11 \
    fonts-dejavu \
    scrot \
    xkb-data \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    openbox \
    obconf \
    tint2 \
    menu \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    wget -O /tmp/google-chrome-stable.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get install -y ./tmp/google-chrome-stable.deb && \
    rm /tmp/google-chrome-stable.deb && \
    apt-get autoclean -y && apt-get autoremove -y && apt-get autopurge -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git clone https://github.com/novnc/noVNC /opt/noVNC && \
    git clone https://github.com/novnc/websockify /opt/noVNC/utils/websockify && \
    chmod +x /opt/noVNC/utils/novnc_proxy && \
    cp /opt/noVNC/vnc.html /opt/noVNC/index.html

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN useradd -m -s /bin/bash devuser

USER devuser
WORKDIR /home/devuser

EXPOSE 6080

CMD ["/entrypoint.sh"]