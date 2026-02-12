# Bitcoin Scripts
Small utility scripts for running and monitoring a Bitcoin node on a Raspberry Pi.

## Included Script
`bitcoin_dashboard.sh` prints a terminal dashboard with host, resource, blockchain, and peer status.
```
Last login: Thu Feb 12 11:15:25 2026 from 192.168.2.50

                    LasVegas ₿itcoin Fullnode Dashboard
 ⠀⠀⠀⠀⣿⡇⠀⢸⣿⡇⠀⠀     -----------------------------------
 ⠸⠿⣿⣿⣿⡿⠿⠿⣿⣿⣿⣶⣄⠀   Hostname  : lasvegas / 192.168.2.100
 ⠀⠀⢸⣿⣿⡇⠀⠀⠀⠈⣿⣿⣿    Uptime    : up 16 weeks, 2 days, 13 hours, 26 minutes
 ⠀⠀⢸⣿⣿⡇⠀⠀⢀⣠⣿⣿⠟
 ⠀⠀⢸⣿⣿⡿⠿⠿⠿⣿⣿⣥⣄⠀   RAM 733 / 7819 used (available: 7086)
 ⠀⠀⢸⣿⣿⡇⠀⠀⠀⠀⢻⣿⣿⣧   CPU load 0.59 1.12 1.37, temp 45.2°C
 ⠀⠀⢸⣿⣿⡇⠀⠀⠀⠀⣼⣿⣿⣿   SSD 792G / 1.8T (used: 45%)
 ⢰⣶⣿⣿⣿⣷⣶⣶⣾⣿⣿⠿⠛⠁
 ⠀⠀⠀⠀⣿⡇⠀⢸⣿⡇⠀⠀⠀⠀   Refreshed: Do 12 Feb 2026 11:26:55 CET

Blockchain size: 787G / 1.8T used

Bitcoin Core status:
   • Version    : 30.2.0
   • Update     : Up to date
   • Chain      : main
   • Blocks     : 936207
   • Headers    : 936207
   • Sync %     : 100.00%
   • IBD Mode   : false
   • Last Block : 15 min ago

Bitcoin network info:
   • Peers       : 10
   • Mempool txs : 15199
   • Uptime      : 1h 35m
```