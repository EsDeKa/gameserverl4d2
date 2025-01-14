# https://github.com/EsDeKa/gameserverl4d2

FROM lanopsdev/gameserver-steamcmd:latest

# Add dependencies
USER root
RUN apt-get update && apt-get install -y git python3

# Env - Defaults
ENV SRCDS_PORT 27015 
# Env - Server
ENV SRCDS_SRV_DIR /home/steam/left4dead2
ENV SRCDS_APP_ID 222860
ENV SERVER_NAME SDK
# Env - SourceMod & MetaMod
ENV SOURCEMOD_VERSION_MAJOR 1.11
ENV SOURCEMOD_VERSION_MINOR 0
ENV SOURCEMOD_BUILD 6876
ENV METAMOD_VERSION_MAJOR 1.12
ENV METAMOD_VERSION_MINOR 0
ENV METAMOD_BUILD 1157

# Auto workshop collection downloader
ENV COLLECTIONS 2787108777 2787147130

# Add start scripts
USER steam
RUN mkdir -p ${SRCDS_SRV_DIR}
ADD --chown=steam:steam resources/root/* /home/steam

# Expose Ports
EXPOSE ${SRCDS_PORT}
EXPOSE ${SRCDS_PORT}/udp

# Start Server

ENTRYPOINT ["/home/steam/start.sh"]
CMD ["+map c7m2_barge +ip 0.0.0.0 +precache_all_survivors 1"]

# Debugging:
# docker run -it --name "esdekal4d2" -v $PWD/content:/home/steam/left4dead2 -p 27035:27035 -p 27035:27035/udp --env SRCDS_PORT=27035 --env SERVER_NAME="SDK_TEST_SERVER" --rm --entrypoint /bin/bash esdeka/gameserverl4d2 