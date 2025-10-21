#!/bin/bash
ORANGE='\e[38;2;247;147;26m'
RESET='\e[0m'

CPU_TEMP_RAW=$(cat /sys/class/thermal/thermal_zone0/temp)
CPU_TEMP=$(echo "scale=1; $CPU_TEMP_RAW / 1000" | bc)
LOAD_AVG=$(cut -d " " -f1-3 /proc/loadavg)

ROOT_DISK=$(df -h / | awk 'NR==2 {print $3 " / " $2 " (used: " $5 ")"}')

MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MEM_AVAILABLE=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
MEM_USED=$((MEM_TOTAL - MEM_AVAILABLE))
MEM_TOTAL_MB=$((MEM_TOTAL / 1024))
MEM_AVAILABLE_MB=$((MEM_AVAILABLE / 1024))
MEM_USED_MB=$((MEM_USED / 1024))

echo ""
echo -e "${ORANGE}                  LasVegas Bitcoin Fullnode Dashboard${RESET}"
echo -e "${ORANGE} ⠀⠀⠀⠀⣿⡇⠀⢸⣿⡇⠀⠀     ${RESET}-----------------------------------"
echo -e "${ORANGE} ⠸⠿⣿⣿⣿⡿⠿⠿⣿⣿⣿⣶⣄⠀   ${RESET}Hostname  : $(hostname) / $(hostname -I | awk '{print $1}')"
echo -e "${ORANGE} ⠀⠀⢸⣿⣿⡇⠀⠀⠀⠈⣿⣿⣿    ${RESET}Uptime    : $(uptime -p)"   
echo -e "${ORANGE} ⠀⠀⢸⣿⣿⡇⠀⠀⢀⣠⣿⣿⠟    ${RESET}"
echo -e "${ORANGE} ⠀⠀⢸⣿⣿⡿⠿⠿⠿⣿⣿⣥⣄⠀   ${RESET}RAM $MEM_USED_MB / $MEM_TOTAL_MB used (available: $MEM_AVAILABLE_MB)"
echo -e "${ORANGE} ⠀⠀⢸⣿⣿⡇⠀⠀⠀⠀⢻⣿⣿⣧   ${RESET}CPU load $LOAD_AVG, temp $CPU_TEMP°C"
echo -e "${ORANGE} ⠀⠀⢸⣿⣿⡇⠀⠀⠀⠀⣼⣿⣿⣿   ${RESET}SSD $ROOT_DISK"
echo -e "${ORANGE} ⢰⣶⣿⣿⣿⣷⣶⣶⣾⣿⣿⠿⠛⠁   ${RESET}"
echo -e "${ORANGE} ⠀⠀⠀⠀⣿⡇⠀⢸⣿⡇⠀⠀⠀⠀   ${RESET}Refreshed: $(date)"
echo ""
BLOCKCHAIN_DISK=$(du -sh ~/.bitcoin 2>/dev/null | awk '{print $1}')
BLOCKCHAIN_TOTAL=$(df -h ~/.bitcoin | awk 'NR==2 {print $2}')
echo "📀 Blockchain: $BLOCKCHAIN_DISK / $BLOCKCHAIN_TOTAL used"
echo ""

# Bitcoin status
if command -v bitcoin-cli &> /dev/null; then

  # Bitcoin Core version
  LOCAL_VERSION=$(bitcoin-cli getnetworkinfo | jq -r .subversion | sed 's|/||g' | cut -d: -f2)
  LATEST_VERSION=$(curl -s https://api.github.com/repos/bitcoin/bitcoin/releases/latest | jq -r .tag_name | sed 's/^v//')

  CHAIN=$(bitcoin-cli getblockchaininfo | jq -r .chain)
  BLOCKS=$(bitcoin-cli getblockchaininfo | jq -r .blocks)
  HEADERS=$(bitcoin-cli getblockchaininfo | jq -r .headers)
  IBD=$(bitcoin-cli getblockchaininfo | jq -r .initialblockdownload)
  RAW_PROGRESS=$(bitcoin-cli getblockchaininfo | jq -r .verificationprogress)
  PROGRESS_PERCENT=$(echo "$RAW_PROGRESS * 100" | bc -l | awk '{printf "%.2f", $1}')

  # Progress bar
  BAR_WIDTH=30
  FILLED=$(printf "%.0f" "$(echo "$RAW_PROGRESS * $BAR_WIDTH" | bc -l)")
  EMPTY=$((BAR_WIDTH - FILLED))
  BAR=$(printf "%0.s█" $(seq 1 $FILLED))
  BAR+=$(printf "%0.s░" $(seq 1 $EMPTY))

  echo "₿ Bitcoin Core status:"
    echo -e "   • Version    : ${ORANGE}${LOCAL_VERSION}${RESET}"
  if [ "$LOCAL_VERSION" != "$LATEST_VERSION" ]; then
    echo -e "   • Update     : ${ORANGE}New version available: $LATEST_VERSION${RESET}"
  else
    echo -e "   • Update     : Up to date"
  fi
  echo "   • Chain      : $CHAIN"
  echo "   • Blocks     : $BLOCKS"
  echo "   • Headers    : $HEADERS"
  echo "   • Sync %     : $PROGRESS_PERCENT%"
  echo "   • Sync Bar   : [$BAR]"
  echo "   • IBD Mode   : $IBD"

  # Time since last block
  LAST_BLOCK_HASH=$(bitcoin-cli getblockhash "$BLOCKS")
  LAST_BLOCK_TIME=$(bitcoin-cli getblock "$LAST_BLOCK_HASH" | jq -r '.time')
  NOW=$(date +%s)
  AGE=$((NOW - LAST_BLOCK_TIME))
  AGE_MIN=$((AGE / 60))
  AGE_STR="$AGE_MIN min ago"
  [[ $AGE -lt 60 ]] && AGE_STR="$AGE sec ago"
  echo "   • Last Block : $AGE_STR"

  # Optional: IBD Warning
  if [[ "$IBD" == "true" ]]; then
    echo "   ⏳ Node is still syncing... Initial Block Download in progress."
  fi

  # Network Info
  CONNECTIONS=$(bitcoin-cli getnetworkinfo | jq '.connections')
  MEMPOOL_SIZE=$(bitcoin-cli getmempoolinfo | jq '.size')
  BTC_UPTIME=$(bitcoin-cli uptime 2>/dev/null)
  TOR_ADDR=$(bitcoin-cli getnetworkinfo | jq -r '.localaddresses[]? | select(.address | endswith(".onion")) | .address')

  echo ""
  echo "📡 Bitcoin Network Info:"
  echo "   • Peers       : $CONNECTIONS"
  echo "   • Mempool txs : $MEMPOOL_SIZE"
  echo "   • Uptime      : $((BTC_UPTIME / 3600))h $(( (BTC_UPTIME % 3600) / 60))m"
  
  if [ -n "$TOR_ADDR" ]; then
    echo "   • Tor Address : $TOR_ADDR"
  fi
else
  echo "Bitcoin Core not available. Check your PATH or install bitcoin-cli."
fi

echo ""
