FROM ubuntu:22.04

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y linux-sound-base alsa-base alsa-utils vlc && \
    useradd --groups audio --shell /bin/sh vlcuser && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY startup.sh /home/vlcuser/startup.sh

RUN chmod +x /home/vlcuser/startup.sh

EXPOSE 4212

WORKDIR /home/vlcuser/

ENTRYPOINT ["/bin/bash", "-c", "/home/vlcuser/startup.sh"]
