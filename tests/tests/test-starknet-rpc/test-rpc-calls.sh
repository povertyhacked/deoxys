#!/bin/bash

URL1="https://deoxys.kasar.io/rpc"
URL2="https://starknet-mainnet.g.alchemy.com/v2/hnj_DGevqpyoyeoEs9Vfx-6qSTHOnaIu"

declare -a Calls=("starknet_getBlockWithTxHashes {\"block_hash\":\"0x053315a56543737cd1b2dc40c60e84d03a9b10d712c9b29f488dc979f0cd56bd\"}"
       "starknet_getBlockWithTxs {\"block_id\":\"50000\"}"
       "starknet_getStateUpdate {\"block_id\":\"50000\"}"
       "starknet_getStorageAt {\"address\":\"0x123\", \"position\":\"0x123\"}" # Replace with valid address and position
       "starknet_getTransactionByHash {\"transaction_hash\":\"0x02d065f142db654e9d0e17f064ad942edfee87a36b029a2c1928ceb704ca2686\"}"
       "starknet_getTransactionByBlockIdAndIndex {\"block_hash\":\"0x053315a56543737cd1b2dc40c60e84d03a9b10d712c9b29f488dc979f0cd56bd\", \"index\":\"0\"}"
       "starknet_getClass {\"address\":\"0x123\"}" # Replace with valid address
       "starknet_getTransactionReceipt {\"transaction_hash\":\"0x02d065f142db654e9d0e17f064ad942edfee87a36b029a2c1928ceb704ca2686\"}"
       "starknet_getClassHashAt {\"address\":\"0x123\", \"position\":\"0x123\"}" # Replace with valid address and position
       "starknet_getClassAt {\"block_id\":\"50000\", \"contract_address\":\"0x07e2a13b40fc1119ec55e0bcf9428eedaa581ab3c924561ad4e955f95da63138\"}" # Replace with valid address and position
       "starknet_getBlockTransactionCount {\"block_hash\":\"0x053315a56543737cd1b2dc40c60e84d03a9b10d712c9b29f488dc979f0cd56bd\"}"
       "starknet_call {\"to\":\"0x123\", \"data\":\"0x123\"}" # Replace with valid address and data
       "starknet_estimateFee {\"to\":\"0x123\", \"value\":\"0x123\", \"gasPrice\":\"0x123\", \"gas\":\"0x123\", \"data\":\"0x123\"}" # Replace with valid address, value, gasPrice, gas, data
       "starknet_estimateMessageFee {\"to\":\"0x123\", \"value\":\"0x123\", \"gasPrice\":\"0x123\", \"gas\":\"0x123\", \"data\":\"0x123\"}" # Replace with valid address, value, gasPrice, gas, data
       "starknet_blockNumber {}"
       "starknet_blockHashAndNumber {\"block_number\":\"50000\"}"
       "starknet_chainId {}")


for call in "${Calls[@]}"; do
    IFS=' ' read -r -a parts <<< "$call"
    method="${parts[0]}"
    params="${parts[1]}"

    echo -e "\033[0;36mTesting endpoint: $method \033[0m"

    echo -e "\033[0;33mURL1: $URL1 \033[0m"
    response1=$(curl -s -X POST $URL1 \
        -H "Content-Type: application/json" \
        -d '{
            "jsonrpc":"2.0",
            "method":"'$method'",
            "params":'$params',
            "id":1
        }')
    echo $response1 | jq -c .

    echo -e "\033[0;33mURL2: $URL2 \033[0m"
    response2=$(curl -s -X POST $URL2 \
        -H "Content-Type: application/json" \
        -d '{
            "jsonrpc":"2.0",
            "method":"'$method'",
            "params":'$params',
            "id":1
        }')
    echo $response2 | jq -c .

    echo -e "\n"
done