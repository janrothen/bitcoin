#!/bin/bash

CPU_TEMP_RAW=$(cat /sys/class/thermal/thermal_zone0/temp)
CPU_TEMP=$(echo "scale=1; $CPU_TEMP_RAW / 1000" | bc)
LOAD_AVG=$(cut -d " " -f1-3 /proc/loadavg)

MEM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
MEM_USED=$(free -h | awk '/^Mem:/ {print $3}')
MEM_FREE=$(free -h | awk '/^Mem:/ {print $4}')
echo "🧠 RAM Usage : $MEM_USED / $MEM_TOTAL used (free: $MEM_FREE)"
ROOT_DISK=$(df -h / | awk 'NR==2 {print $3 " / " $2 " used (" $5 ")"}')
echo "💾 Disk Root : $ROOT_DISK"

echo ""
echo "                   LasVegas Bitcoin Fullnode Dashboard"
echo "                   -----------------------------------"
echo " ⠀⠀⠀⠀⣿⡇⠀⢸⣿⡇⠀⠀⠀     Refreshed: $(date)"
echo "⠸⠿⣿⣿⣿⡿⠿⠿⣿⣿⣿⣶⣄⠀     CPU load $LOAD_AVG, temp $CPU_TEMP°C"
echo "⠀⠀⢸⣿⣿⡇⠀⠀⠀⠈⣿⣿⣿⠀     Free Mem 3072M/ 3792M, SSD $ROOT_DISK"
echo "⠀⠀⢸⣿⣿⡇⠀⠀⢀⣠⣿⣿⠟⠀ "
echo "⠀⠀⢸⣿⣿⡿⠿⠿⠿⣿⣿⣥⣄⠀ "
echo "⠀⠀⢸⣿⣿⡇⠀⠀⠀⠀⢻⣿⣿⣧ "
echo "⠀⠀⢸⣿⣿⡇⠀⠀⠀⠀⣼⣿⣿⣿ "
echo "⢰⣶⣿⣿⣿⣷⣶⣶⣾⣿⣿⠿⠛⠁ "
echo "⠀⠀⠀⠀⣿⡇⠀⢸⣿⡇⠀⠀⠀⠀ "

echo ""
echo "🕒 Date      : $(date)"
echo "🔄 Uptime    : $(uptime -p)"
echo "📦 Hostname  : $(hostname)"
echo "🌐 IP Addr   : $(hostname -I | awk '{print $1}')"
echo ""


BLOCKCHAIN_DISK=$(du -sh ~/.bitcoin 2>/dev/null | awk '{print $1}')
BLOCKCHAIN_TOTAL=$(df -h ~/.bitcoin | awk 'NR==2 {print $2}')
echo "📀 Blockchain: $BLOCKCHAIN_DISK / $BLOCKCHAIN_TOTAL used"
echo ""

# Bitcoin status
if command -v bitcoin-cli &> /dev/null; then
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
