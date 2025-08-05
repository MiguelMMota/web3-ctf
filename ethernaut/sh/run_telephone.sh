#!/bin/bash

# Use the first command-line argument as the RPC_URL
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Missing required arguments."
    echo "Usage: $0 <RPC_URL> <ACCOUNT>"
    exit 1
fi

RPC_URL="$1"
ACCOUNT="$2"

echo "Starting Docker containers..."
docker-compose up -d
echo "Docker containers started."

sleep 5

echo "Deploying Telephone attack contract...";
cmd="docker exec -it foundry-dev forge script script/TelephoneAttacker.s.sol --rpc-url $RPC_URL --account $ACCOUNT --password-file .password --broadcast -vvvv --tc TelephoneAttacker";

output=$($cmd 2>&1)
exit_code=$?
if [ $exit_code -eq 0 ]; then
    echo "--- Deployment completed successfully. ---"
else
    echo "--- Deployment FAILED. Check the detailed traces above for the revert reason. ---"
    echo "output: $output";
    exit 1
fi

# Extract using the console log
address=$(echo "$output" | grep -oE "DEPLOYED_ADDRESS: 0x[a-fA-F0-9]{40}" | grep -oE "0x[a-fA-F0-9]{40}" | head -1)

if [ -z "$address" ]; then
    echo "ERROR: Could not extract DEPLOYED_ADDRESS from console logs"
    echo "Full output:"
    echo "$output"
    exit 1
fi
        
echo "Attacking with Telephone attack contract at $address";
docker exec -it -e ATTACK_CONTRACT="$address" foundry-dev forge script script/ExecuteTelephoneAttack.s.sol --rpc-url $RPC_URL --account $ACCOUNT --password-file .password --broadcast -vvvv;

exit_code=$?
if [ $exit_code -eq 0 ]; then
    echo "--- Attack completed successfully. ---"
else
    echo "--- Attack FAILED. Check the detailed traces above for the revert reason. ---"
    exit 1
fi

echo ""
echo "Telephone attack complete"

echo "Stopping Docker containers..."
docker-compose down
echo "Docker containers stopped."