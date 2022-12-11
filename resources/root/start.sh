#!/bin/bash

if [ ! -d "${SRCDS_SRV_DIR}" ]; then
    echo "Initial setup '${SRCDS_SRV_DIR}' folder"
    mkdir ${SRCDS_SRV_DIR}
fi

cd ${SRCDS_SRV_DIR}

while true
do
    if [ ! -f "${SRCDS_SRV_DIR}/runServer.sh" ]; then
        echo "Copy runServer_.sh"
        cp ~/runServer_.sh ${SRCDS_SRV_DIR}/runServer.sh
    fi
    if [ ! -f "dontrun" ]; then
        ${SRCDS_SRV_DIR}/runServer.sh $@
    else
        /bin/bash
    fi    
done
