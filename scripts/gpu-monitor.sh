#!/usr/bin/env bash
# Real-time AMD GPU monitoring script
# Displays GPU stats continuously with color-coded output

set -euo pipefail

GPU_DEVICE="/sys/class/drm/card0/device"
GPU_HWMON="/sys/class/drm/card0/device/hwmon/hwmon2"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Get temperature with color coding
get_temp_color() {
  local temp=$1
  if [ "$temp" -gt 80 ]; then
    echo -e "${RED}${temp}°C${NC}"
  elif [ "$temp" -gt 70 ]; then
    echo -e "${YELLOW}${temp}°C${NC}"
  else
    echo -e "${GREEN}${temp}°C${NC}"
  fi
}

# Get utilization with color coding
get_util_color() {
  local util=$1
  if [ "$util" -gt 90 ]; then
    echo -e "${RED}${util}%${NC}"
  elif [ "$util" -gt 70 ]; then
    echo -e "${YELLOW}${util}%${NC}"
  else
    echo -e "${GREEN}${util}%${NC}"
  fi
}

# Main monitoring loop
monitor_gpu() {
  local interval="${1:-1}"

  while true; do
    clear
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}         AMD Radeon RX 7900 XT/XTX Monitor${NC}"
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""

    # Read all values
    local temp1=$(($(cat "$GPU_HWMON/temp1_input") / 1000))
    local temp2=$(($(cat "$GPU_HWMON/temp2_input") / 1000))
    local temp3=$(($(cat "$GPU_HWMON/temp3_input") / 1000))
    local gpu_util=$(cat "$GPU_DEVICE/gpu_busy_percent")
    local mem_util=$(cat "$GPU_DEVICE/mem_busy_percent")
    local power=$(($(cat "$GPU_HWMON/power1_average") / 1000000))
    local power_cap=$(($(cat "$GPU_HWMON/power1_cap") / 1000000))
    local fan_speed=$(cat "$GPU_HWMON/fan1_input")
    local sclk=$(grep '\*' "$GPU_DEVICE/pp_dpm_sclk" | awk '{print $2}' | sed 's/Mhz//')
    local mclk=$(grep '\*' "$GPU_DEVICE/pp_dpm_mclk" | awk '{print $2}' | sed 's/Mhz//')
    local vram_total=$(cat "$GPU_DEVICE/mem_info_vram_total")
    local vram_used=$(cat "$GPU_DEVICE/mem_info_vram_used")
    local vram_mb_used=$((vram_used / 1024 / 1024))
    local vram_mb_total=$((vram_total / 1024 / 1024))
    local vram_percent=$((vram_used * 100 / vram_total))

    # Display
    echo -e "${BOLD}Temperatures:${NC}"
    printf "  Edge:         %s\n" "$(get_temp_color "$temp1")"
    printf "  Junction:     %s\n" "$(get_temp_color "$temp2")"
    printf "  Memory:       %s\n" "$(get_temp_color "$temp3")"
    echo ""

    echo -e "${BOLD}Utilization:${NC}"
    printf "  GPU:          %s\n" "$(get_util_color "$gpu_util")"
    printf "  Memory:       %s\n" "$(get_util_color "$mem_util")"
    echo ""

    echo -e "${BOLD}Clock Speeds:${NC}"
    printf "  GPU:          ${BLUE}%4d MHz${NC}\n" "$sclk"
    printf "  Memory:       ${BLUE}%4d MHz${NC}\n" "$mclk"
    echo ""

    echo -e "${BOLD}Power:${NC}"
    printf "  Current:      ${YELLOW}%3d W${NC} / %d W\n" "$power" "$power_cap"

    # Power bar
    local power_percent=$((power * 100 / power_cap))
    local bar_width=40
    local filled=$((power_percent * bar_width / 100))
    printf "  ["
    for ((i = 0; i < bar_width; i++)); do
      if [ $i -lt "$filled" ]; then
        printf "█"
      else
        printf "░"
      fi
    done
    printf "] %d%%\n" "$power_percent"
    echo ""

    echo -e "${BOLD}Fan:${NC}"
    printf "  Speed:        ${CYAN}%4d RPM${NC}\n" "$fan_speed"
    echo ""

    echo -e "${BOLD}VRAM:${NC}"
    printf "  Usage:        ${GREEN}%5d MB${NC} / %5d MB (%d%%)\n" \
      "$vram_mb_used" "$vram_mb_total" "$vram_percent"

    # VRAM bar
    local vram_bar_width=40
    local vram_filled=$((vram_percent * vram_bar_width / 100))
    printf "  ["
    for ((i = 0; i < vram_bar_width; i++)); do
      if [ $i -lt "$vram_filled" ]; then
        printf "█"
      else
        printf "░"
      fi
    done
    printf "] %d%%\n" "$vram_percent"

    echo ""
    echo -e "${BOLD}${CYAN}───────────────────────────────────────────────────────────${NC}"
    echo -e "Press ${BOLD}Ctrl+C${NC} to exit | Refresh: ${interval}s"

    sleep "$interval"
  done
}

# Parse arguments
INTERVAL=1

while [[ $# -gt 0 ]]; do
  case $1 in
  -i | --interval)
    INTERVAL="$2"
    shift 2
    ;;
  -h | --help)
    echo "Usage: $0 [-i|--interval SECONDS]"
    echo ""
    echo "Real-time AMD GPU monitoring"
    echo ""
    echo "Options:"
    echo "  -i, --interval SECONDS    Update interval (default: 1)"
    echo "  -h, --help               Show this help"
    exit 0
    ;;
  *)
    echo "Unknown option: $1"
    exit 1
    ;;
  esac
done

monitor_gpu "$INTERVAL"
