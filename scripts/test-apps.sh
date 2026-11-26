#!/usr/bin/env bash
set -euo pipefail
# Uso: bash scripts/test-apps.sh external
#      bash scripts/test-apps.sh local IP_PRIVADO_DA_VM
MODE=${1:-external}
case "$MODE" in
  external) HOST=${2:-150.165.85.77}; CPU=8025; MEMORY=8125; IO=8225 ;;
  local) HOST=${2:?Informe o IP privado da VM}; CPU=8001; MEMORY=8002; IO=8003 ;;
  *) echo 'Use external ou local.' >&2; exit 2 ;;
esac
request() {
  echo "$1"
  curl --fail --silent --show-error --max-time 30 "$1"
  printf '\n\n'
}
request "http://$HOST:$CPU/health"
request "http://$HOST:$MEMORY/health"
request "http://$HOST:$IO/health"
request "http://$HOST:$CPU/cpu?n=100000"
request "http://$HOST:$MEMORY/memory?mb=50&hold_ms=1000"
request "http://$HOST:$IO/io?mb=20"