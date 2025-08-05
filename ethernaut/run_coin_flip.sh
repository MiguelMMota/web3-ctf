#!/bin/bash

# --- Configuration ---

# Number of times to run the entire CoinFlip.s.sol script.
# We flip the coin once each time we run the script
TARGET_CONSECUTIVE_WINS=10

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

echo "Starting coin flips (total: $TARGET_CONSECUTIVE_WINS attempts)..."

get_latest_block() {
  curl -s -X POST \
    -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
    "$RPC_URL" | jq -r '.result' | xargs printf "%d\n"
}

wait_for_new_block() {
  local prev_block=$1
  local new_block
  while true; do
    new_block=$(get_latest_block)
    if [ "$new_block" -gt "$prev_block" ]; then
      echo "New block detected: $new_block"
      break
    fi
    sleep 2
  done
}

wait_for_tx_confirmation() {
  local tx_hash=$1
  while true; do
    receipt=$(curl -s -X POST \
      -H "Content-Type: application/json" \
      --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getTransactionReceipt\",\"params\":[\"$tx_hash\"],\"id\":1}" \
      "$RPC_URL")
    status=$(echo "$receipt" | jq -r '.result.status')
    if [ "$status" != "null" ]; then
      echo "Transaction $tx_hash confirmed with status: $status"
      break
    fi
    sleep 2
  done
}

for i in $(seq 1 $TARGET_CONSECUTIVE_WINS); do
  echo ""
  echo "--- Running CoinFlip Script Attempt $i of $TARGET_CONSECUTIVE_WINS ---"
  cmd="docker exec -it foundry-dev forge script script/CoinFlipAttacker.s.sol --rpc-url $RPC_URL --account $ACCOUNT --password-file .password --broadcast -vvvv --tc CoinFlipAttacker"
  echo "Executing: $cmd"
  echo ""

  # Run the script and capture output and exit code
  output=$($cmd 2>&1)
  exit_code=$?

  # See README section for exercise 3. We can't be sure that the block before the attack is the block that
  # the attacking transaction was included in, so we wait until another block is mined after our attack.
  # There's probably a better way to do this, but I don't want to spend more time optimising this.
  end_block=$(get_latest_block)
  echo "Block at the end of attack: $end_block"

  # echo "Output: $output" > $i.log

  # Extract tx hash (assumes "Hash: 0x..." appears in output)
  tx_hash=$(echo "$output" | grep -oE 'Hash: 0x[a-fA-F0-9]+' | head -1 | awk '{print $2}')
  if [ -n "$tx_hash" ]; then
    wait_for_tx_confirmation "$tx_hash"
  else
    echo "Warning: Could not extract transaction hash from output."
  fi

  # Wait for a new block
  wait_for_new_block "$end_block"

  # Log the new block number
  new_block=$(get_latest_block)
  echo "Got new block $i: $new_block"

  if [ $exit_code -eq 0 ]; then
    echo "--- Attempt $i completed successfully. ---"
  else
    echo "--- Attempt $i FAILED. Check the detailed traces above for the revert reason. ---"
    exit 1
  fi
done

echo ""
echo "All CoinFlip script attempts finished."

echo "Stopping Docker containers..."
docker-compose down
echo "Docker containers stopped."