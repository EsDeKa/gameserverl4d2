# https://github.com/EsDeKa/gameserverl4d2

FROM lanopsdev/gameserver-steamcmd:latest

# Env - Defaults
ENV SRCDS_PORT 27015 
# Env - Server
ENV SRCDS_SRV_DIR /home/steam/left4dead2
ENV SRCDS_APP_ID 222860
ENV SERVER_NAME SDK
# Env - SourceMod & MetaMod
ENV SOURCEMOD_VERSION_MAJOR 1.12
ENV SOURCEMOD_VERSION_MINOR 0
ENV SOURCEMOD_BUILD 6936
ENV METAMOD_VERSION_MAJOR 1.12
ENV METAMOD_VERSION_MINOR 0
ENV METAMOD_BUILD 1164
# Auto workshop collection downloader
ENV COLLECTIONS 2787108777 2787147130

# Add dependencies
USER root
RUN apt-get update && apt-get install -y git python3

# Add start scripts
USER steam
RUN mkdir -p ${SRCDS_SRV_DIR}
ADD --chown=steam:steam resources/root/* /home/steam

# Expose Ports

EXPOSE ${SRCDS_PORT}
EXPOSE ${SRCDS_PORT}/udp
#EXPOSE 27020 27005 51840

# Start Server

ENTRYPOINT ["/home/steam/startServer.sh"]
CMD ["+map c7m2_barge +ip 0.0.0.0"]

# Debugging:
# docker run -it --name "esdekal4d2" -v $PWD/content:/home/steam/left4dead2 -p 27035:27035 -p 27035:27035/udp --env SRCDS_PORT=27035 --env SERVER_NAME="SDK_TEST_SERVER" --rm --entrypoint /bin/bash esdeka/gameserverl4d2 