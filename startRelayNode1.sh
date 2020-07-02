#!/usr/bin/env bash
#
# This script is based of the following guide:
# https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node
#
# Restarts the relay node periodically if it's not already running.
#
# Line 10-13 should be added to: "crontab -e"
: <<'COMMENT'
* * * * * /usr/bin/bash ${HOME}/cardano-my-node/relaynode1/startRelayNode1.sh
* * * * * ( sleep 15 ; usr/bin/bash ${HOME}/cardano-my-node/relaynode1/startRelayNode1.sh )
* * * * * ( sleep 30 ; usr/bin/bash ${HOME}/cardano-my-node/relaynode1/startRelayNode1.sh )
* * * * * ( sleep 45 ; usr/bin/bash ${HOME}/cardano-my-node/relaynode1/startRelayNode1.sh )
COMMENT
# To attach to the UI use: "tmux a -t relay_1"

PORT=3001
if ! lsof -i:${PORT} -sTCP:LISTEN > /dev/null
then
    SESSION=relay_1
    DIRECTORY=/home/kaze/cardano-my-node/relaynode1
    export CARDANO_NODE_SOCKET_PATH="${DIRECTORY}/db/socket"
    HOSTADDR=0.0.0.0
    TOPOLOGY=${DIRECTORY}/shelley_testnet-topology.json
    DB_PATH=${DIRECTORY}/db
    SOCKET_PATH=${DIRECTORY}/db/socket
    CONFIG=${DIRECTORY}/shelley_testnet-config.json



    /usr/bin/tmux has-session -t ${SESSION} 2>/dev/null
    if [ $? != 0 ]
    then
        /usr/bin/tmux new-session -d -s ${SESSION} "/usr/local/bin/cardano-node run --topology ${TOPOLOGY} --database-path ${DB_PATH} --socket-path ${SOCKET_PATH} --host-addr ${HOSTADDR} --port ${PORT} --config ${CONFIG}"
    else
        /usr/bin/tmux kill-session -t ${SESSION}
        /usr/bin/tmux new-session -d -s ${SESSION} "/usr/local/bin/cardano-node run --topology ${TOPOLOGY} --database-path ${DB_PATH} --socket-path ${SOCKET_PATH} --host-addr ${HOSTADDR} --port ${PORT} --config ${CONFIG}"
    fi
fi