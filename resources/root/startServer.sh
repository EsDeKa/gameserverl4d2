#!/bin/bash

cd ${SRCDS_SRV_DIR}

getMetaMod="false"
getSourceMod="false"

if [ ! -d "left4dead2" ];
then
    mkdir left4dead2
    cp -r /tmp/cfg left4dead2/cfg/
fi

# Check if MetaMod Needs updating

if [ ! -d "left4dead2/addons/metamod" ] || [ ! -f "left4dead2/addons/mm-version" ];
then
    echo "Getting Metamod"
    getMetaMod="true"
fi
if [ -f "left4dead2/addons/mm-version" ];
then
    content=$(head -n 1 left4dead2/addons/mm-version)
    if [ "${METAMOD_VERSION_MAJOR}.${METAMOD_VERSION_MINOR}-${METAMOD_BUILD}" != "$content" ];
    then
        echo "Getting Metamod"
        getMetaMod="true"
    fi
fi

# Check if SourceMod Needs updating

if [ ! -d "left4dead2/addons/sourcemod" ] || [ ! -f "left4dead2/addons/sm-version" ];
then
    echo "Getting Sourcemod"
    getSourceMod="true"
fi
if [ -f "left4dead2/addons/sm-version" ];
then
    content=$(head -n 1 left4dead2/addons/sm-version)
    if [ "${SOURCEMOD_VERSION_MAJOR}.${SOURCEMOD_VERSION_MINOR}-${SOURCEMOD_BUILD}" != "$content" ];
    then
        echo "Getting Sourcemod"
        getSourceMod="true"
    fi
fi

# Update MetaMod

if [ "$getMetaMod" = "true" ];
then
    curl -sSL https://mms.alliedmods.net/mmsdrop/$METAMOD_VERSION_MAJOR/mmsource-$METAMOD_VERSION_MAJOR.$METAMOD_VERSION_MINOR-git$METAMOD_BUILD-linux.tar.gz \
        -o /tmp/metamod.tar.gz
    tar -xzvf /tmp/metamod.tar.gz --directory $SRCDS_SRV_DIR/left4dead2
    rm /tmp/metamod.tar.gz
    if [ -f "left4dead2/addons/mm-version" ];
    then
        rm left4dead2/addons/mm-version
    fi
    echo "${METAMOD_VERSION_MAJOR}.${METAMOD_VERSION_MINOR}-${METAMOD_BUILD}" > left4dead2/addons/mm-version
fi

# Update SourceMod

if [ "$getSourceMod" = "true" ];
then
    curl -sSL https://sm.alliedmods.net/smdrop/$SOURCEMOD_VERSION_MAJOR/sourcemod-$SOURCEMOD_VERSION_MAJOR.$SOURCEMOD_VERSION_MINOR-git$SOURCEMOD_BUILD-linux.tar.gz \
        -o /tmp/sourcemod.tar.gz
    tar -xzvf /tmp/sourcemod.tar.gz --directory $SRCDS_SRV_DIR/left4dead2
    rm /tmp/sourcemod.tar.gz
    if [ -f "left4dead2/addons/sm-version" ];
    then
        rm left4dead2/addons/sm-version
    fi
    echo "${SOURCEMOD_VERSION_MAJOR}.${SOURCEMOD_VERSION_MINOR}-${SOURCEMOD_BUILD}" > left4dead2/addons/sm-version
fi

# Pull EsDeKa resources
if [ "$getSourceMod" = "true" ];
then
    echo "Cloning resources:"
    git clone https://github.com/EsDeKa/l4d2server-resources.git
    cp -R l4d2server-resources/. .
    rm -R --interactive=never l4d2server-resources/
fi

if [ -f "left4dead2/addons/sourcemod/plugins/nextmap.smx" ];
then
    echo "Disabling useless nextmap.smx"
    mv left4dead2/addons/sourcemod/plugins/nextmap.smx left4dead2/addons/sourcemod/plugins/disabled/
fi

# Configure server name in separate cfg file
echo hostname \"${SERVER_NAME:-SDK}\" > left4dead2/cfg/private_env.cfg

# Run Server

echo "-----------Initial steamcmd update and validate -----------"
/home/steam/steamcmd/steamcmd.sh +login anonymous   \
        +force_install_dir ${SRCDS_SRV_DIR}         \
        +app_update ${SRCDS_APP_ID}                 \
        +quit


while true
do 
    if [ -v COLLECTIONS ]; then
        echo "-----------Syncing with workshop.py-----------"
        python3 /home/steam/workshop.py                     \
            -o ~/left4dead2/left4dead2/addons/workshop/     \
            ${COLLECTIONS}
    fi
        
    echo "-----------Starting srcds_run-----------"
    ./srcds_run                                         \
        -game left4dead2                                \
        -console                                        \
        -usercon                                        \
        -steam_dir /home/steam/steamcmd                 \
        -steamcmd_script /home/steam/autoupdate.txt     \
        -port ${SRCDS_PORT}                             \
        $@

    echo "-----------Server stopped, restarting steamcmd.sh-----------"
    /home/steam/steamcmd/steamcmd.sh +login anonymous   \
            +force_install_dir ${SRCDS_SRV_DIR}         \
            +app_update ${SRCDS_APP_ID}                 \
            +quit
done
