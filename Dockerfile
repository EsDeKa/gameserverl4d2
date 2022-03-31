FROM lanopsdev/gameserver-steamcmd:latest

# Env - Defaults

ENV SRCDS_PORT 27015 

# Env - Server

ENV SRCDS_SRV_DIR /home/steam/left4dead2
ENV SRCDS_APP_ID 222860
ENV COLLECTIONS 2787108777 2787147130

# Env - SourceMod & MetaMod

ENV SOURCEMOD_VERSION_MAJOR 1.11
ENV SOURCEMOD_VERSION_MINOR 0
ENV SOURCEMOD_BUILD 6863
ENV METAMOD_VERSION_MAJOR 1.12
ENV METAMOD_VERSION_MINOR 0
ENV METAMOD_BUILD 1157

# Add Start Script
USER root
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y git python3
USER steam
RUN mkdir -p ${SRCDS_SRV_DIR}
RUN { \
        echo '@ShutdownOnFailedCommand 1'; \
        echo '@NoPromptForPassword 1'; \
        echo 'login anonymous'; \
        echo 'force_install_dir $SRCDS_SRV_DIR'; \
        echo 'app_update $SRCDS_APP_ID'; \
        echo 'quit'; \
} > /home/steam/left4dead2_update.txt
ADD resources/root/startServer.sh /home/steam/startServer.sh

# Pre Load LanOps Server Configs & Addons

RUN mkdir -p ${SRCDS_SRV_DIR}/left4dead2/cfg/
COPY resources/root/cfg /tmp/cfg/
RUN mkdir /tmp/dump
RUN chmod -R 777 /tmp/dump

# Expose Ports

EXPOSE ${SRCDS_PORT}
EXPOSE ${SRCDS_PORT}/udp
EXPOSE 27020 27005 51840

# Start Server

ENTRYPOINT ["/home/steam/startServer.sh"]
CMD ["+map c7m2_barge +ip 0.0.0.0"]
