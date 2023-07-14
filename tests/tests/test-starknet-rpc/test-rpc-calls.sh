#!/bin/bash

URL1="http://127.0.0.1:9944/"
URL2="https://starknet-mainnet.g.alchemy.com/v2/hnj_DGevqpyoyeoEs9Vfx-6qSTHOnaIu"

declare -a Calls=(
    "starknet_getBlockWithTxHashes [\"latest\"]"
    "starknet_getBlockWithTxs {\"block_id\":\"latest\"}"
    "starknet_getStateUpdate {\"block_id\":\"latest\"}"
    "starknet_getStorageAt [\"0x0000000000000000000000000000000000000000000000000000000000001111\",\"0x02900ac0f31b4cd8101abb46a91021989eb7c9f6e2a5417186e476f08429efce\",\"latest\"]" # Replace with valid address and position
    "starknet_getTransactionByHash {\"transaction_hash\":\"0x00bafd9ad9de77204d57f5cbc785c47539c097b1b2f44c6728241d2ec717bc3b\"}"
    "starknet_getTransactionByBlockIdAndIndex {\"latest\", \"0\"}"
    "starknet_getClass [\"latest\", \"0x04c53698c9a42341e4123632e87b752d6ae470ddedeb8b0063eaa2deea387eeb\"]"
    "starknet_getTransactionReceipt {\"transaction_hash\":\"0x4c1672e824b5cd7477fca31ee3ab5a1058534ed1820bb27abc976c2e6095151\"}"
    "starknet_getClassHashAt [\"latest\",\"0x03196ed5229c91380bb3045a8236c63e7436e5800b855c107095cbb6496eafd4\"]"
    "starknet_getClassAt {\"latest\",\"contract_address\":\"0x07e2a13b40fc1119ec55e0bcf9428eedaa581ab3c924561ad4e955f95da63138\"}" # Replace with valid address and position
    "starknet_getBlockTransactionCount {\"block_hash\":\"0x053315a56543737cd1b2dc40c60e84d03a9b10d712c9b29f488dc979f0cd56bd\"}"
    "starknet_call { \"request\": { \"contract_address\": \"0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7\", \"entry_point_selector\": \"0x361458367e696363fbcc70777d07ebbd2394e89fd0adcaf147faccd1d294d60\", \"calldata\": [] }, \"latest\" }" # Replace with valid address and data
    "starknet_estimateFee [\"latest\",\"{\"type\":\"INVOKE\",\"nonce\":\"0x0\",\"max_fee\":\"0x12C72866EFA9B\",\"version\":\"0x0\",\"signature\":[\"0x10E400D046147777C2AC5645024E1EE81C86D90B52D76AB8A8125E5F49612F9\",\"0x0ADB92739205B4626FEFB533B38D0071EB018E6FF096C98C17A6826B536817B\"],\"contract_address\":\"0x0019fcae2482de8fb3afaf8d4b219449bec93a5928f02f58eef645cc071767f4\",\"calldata\":[\"0x0000000000000000000000000000000000000000000000000000000000000001\",\"0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7\",\"0x0083afd3f4caedc6eebf44246fe54e38c95e3179a5ec9ea81740eca5b482d12e\",\"0x0000000000000000000000000000000000000000000000000000000000000000\",\"0x0000000000000000000000000000000000000000000000000000000000000003\",\"0x0000000000000000000000000000000000000000000000000000000000000003\",\"0x04681402a7ab16c41f7e5d091f32fe9b78de096e0bd5962ce5bd7aaa4a441f64\",\"0x000000000000000000000000000000000000000000000000001d41f6331e6800\",\"0x0000000000000000000000000000000000000000000000000000000000000000\",\"0x0000000000000000000000000000000000000000000000000000000000000001\" ],\"entry_point_selector\":\"0x015d40a3d6ca2ac30f4031e42be28da9b056fef9bb7357ac5e85627ee876e5ad\"}\"]"
    "starknet_blockNumber {}"
    "starknet_blockHashAndNumber {\"block_number\":\"50000\"}"
    "starknet_chainId {}"
)

declare -i successes=0
declare -i failures=0
declare -i parse_errors=0

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

    echo -e "\033[0;33mURL2: $URL2 \033[0m"
    response2=$(curl -s -X POST $URL2 \
        -H "Content-Type: application/json" \
        -d '{
            "jsonrpc":"2.0",
            "method":"'$method'",
            "params":'$params',
            "id":1
        }')

    # Compare responses
    if [[ "$response1" == *'"error":'* && "$response2" == *'"result":'* ]]; then
        echo -e "\033[0;31m❌ $method - Different response in URLs \033[0m"
        echo -e "Response in URL1 (Local RPC):"
        echo "$response1" | jq -c .
        echo -e "Response in URL2 (Official RPC Provider):"
        echo "$response2" | jq -c .
        failures+=1
    elif [[ "$response1" == *'"result":'* && "$response2" == *'"error":'* ]]; then
        echo -e "\033[0;31m❌ $method - Different response in URLs \033[0m"
        echo -e "Response in URL1 (Local RPC):"
        echo "$response1" | jq -c .
        echo -e "Response in URL2 (Official RPC Provider):"
        echo "$response2" | jq -c .
        failures+=1
    elif [[ "$response1" == *'"error":'* && "$response2" == *'"error":'* ]]; then
        # Both URLs have parse error
        echo -e "\033[0;31m❌ $method - Parse error in both URLs \033[0m"
        parse_errors+=1
    else
        # Valid comparison when both URLs have a "result" field
        echo -e "\033[0;32m✅ $method - Same response in both URLs \033[0m"
        successes+=1
    fi

    echo -e "\n"
done

echo -e "\033[0;36mResults: \033[0m"
echo -e "Successes: $successes"
echo -e "Failures: $failures"
echo -e "Parse Errors: $parse_errors"
