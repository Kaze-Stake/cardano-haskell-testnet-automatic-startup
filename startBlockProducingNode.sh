#!/usr/bin/env bash
#
# This script is based of the following guide:
# https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node
#
# Restarts the block producing node periodically if it's not already running.
#
# Line 10-13 should be added to: "crontab -e"
: <<'COMMENT'
* * * * * /usr/bin/bash ${HOME}/cardano-my-node/startBlockProducingNode.sh
* * * * * ( sleep 15 ; usr/bin/bash ${HOME}/cardano-my-node/startBlockProducingNode.sh )
* * * * * ( sleep 30 ; usr/bin/bash ${HOME}/cardano-my-node/startBlockProducingNode.sh )
* * * * * ( sleep 45 ; usr/bin/bash ${HOME}/cardano-my-node/startBlockProducingNode.sh )
COMMENT
# To attach to the UI use: "tmux a -t block_producer"

PORT=3000
if ! lsof -i:${PORT} -sTCP:LISTEN > /dev/null
then
    SESSION=block_producer
    DIRECTORY=~/cardano-my-node
    export CARDANO_NODE_SOCKET_PATH="${DIRECTORY}/db/socket"
    HOSTADDR=0.0.0.0
    TOPOLOGY=${DIRECTORY}/shelley_testnet-topology.json
    DB_PATH=${DIRECTORY}/db
    SOCKET_PATH=${DIRECTORY}/db/socket
    CONFIG=${DIRECTORY}/shelley_testnet-config.json
    KES=${DIRECTORY}/kes.skey
    VRF=${DIRECTORY}/vrf.skey
    CERT=${DIRECTORY}/node.cert
    /usr/bin/tmux has-session -t ${SESSION} 2>/dev/null
    if [ $? != 0 ]
    then
        /usr/bin/tmux new-session -d -s ${SESSION} "/usr/local/bin/cardano-node run --topology ${TOPOLOGY} --database-path ${DB_PATH} --socket-path ${SOCKET_PATH} --host-addr ${HOSTADDR} --port ${PORT} --config ${CONFIG} --shelley-kes-key ${KES} --shelley-vrf-key ${VRF} --shelley-operational-certificate ${CERT}"
    else
        /usr/bin/tmux kill-session -t ${SESSION}
        /usr/bin/tmux new-session -d -s ${SESSION} "/usr/local/bin/cardano-node run --topology ${TOPOLOGY} --database-path ${DB_PATH} --socket-path ${SOCKET_PATH} --host-addr ${HOSTADDR} --port ${PORT} --config ${CONFIG} --shelley-kes-key ${KES} --shelley-vrf-key ${VRF} --shelley-operational-certificate ${CERT}"
    fi
fi
