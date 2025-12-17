# AMD GPU monitoring functions for Radeon RX 7900 XT/XTX
# Requires user to be in 'video' and 'render' groups

GPU_DEVICE="/sys/class/drm/card0/device"
GPU_HWMON="/sys/class/drm/card0/device/hwmon/hwmon2"

# Main GPU status function - shows comprehensive GPU information
gpu-status() {
  echo "🎮 AMD Radeon RX 7900 XT/XTX Status"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  # Temperatures
  echo "🌡️  Temperatures:"
  local temp1=$(cat "$GPU_HWMON/temp1_input")
  local temp2=$(cat "$GPU_HWMON/temp2_input")
  local temp3=$(cat "$GPU_HWMON/temp3_input")
  printf "   Edge:     %3d°C\n" $((temp1 / 1000))
  printf "   Junction: %3d°C\n" $((temp2 / 1000))
  printf "   Memory:   %3d°C\n" $((temp3 / 1000))
  echo ""

  # Utilization
  echo "📊 Utilization:"
  local gpu_util=$(cat "$GPU_DEVICE/gpu_busy_percent")
  local mem_util=$(cat "$GPU_DEVICE/mem_busy_percent")
  printf "   GPU:    %3d%%\n" "$gpu_util"
  printf "   Memory: %3d%%\n" "$mem_util"
  echo ""

  # Clock speeds
  echo "⚡ Clock Speeds:"
  local sclk=$(grep '\*' "$GPU_DEVICE/pp_dpm_sclk" | awk '{print $2}')
  local mclk=$(grep '\*' "$GPU_DEVICE/pp_dpm_mclk" | awk '{print $2}')
  echo "   GPU Clock:    $sclk"
  echo "   Memory Clock: $mclk"
  echo ""

  # Power
  echo "🔋 Power:"
  local power=$(cat "$GPU_HWMON/power1_average")
  local power_cap=$(cat "$GPU_HWMON/power1_cap")
  printf "   Current: %3dW\n" $((power / 1000000))
  printf "   Limit:   %3dW\n" $((power_cap / 1000000))
  echo ""

  # Fan
  echo "🌀 Fan:"
  local fan_speed=$(cat "$GPU_HWMON/fan1_input")
  local fan_enable=$(cat "$GPU_HWMON/fan1_enable")
  printf "   Speed: %4d RPM" "$fan_speed"
  if [ "$fan_enable" = "1" ]; then
    echo " (auto)"
  else
    echo " (manual)"
  fi
  echo ""

  # VRAM usage
  echo "💾 VRAM Usage:"
  local vram_total=$(cat "$GPU_DEVICE/mem_info_vram_total")
  local vram_used=$(cat "$GPU_DEVICE/mem_info_vram_used")
  local vram_percent=$((vram_used * 100 / vram_total))
  printf "   Used:  %5dMB / %5dMB (%d%%)\n" \
    $((vram_used / 1024 / 1024)) \
    $((vram_total / 1024 / 1024)) \
    "$vram_percent"
}

# Quick temperature check
gpu-temp() {
  local temp1=$(cat "$GPU_HWMON/temp1_input")
  local temp2=$(cat "$GPU_HWMON/temp2_input")
  local temp3=$(cat "$GPU_HWMON/temp3_input")
  printf "Edge: %d°C | Junction: %d°C | Memory: %d°C\n" \
    $((temp1 / 1000)) \
    $((temp2 / 1000)) \
    $((temp3 / 1000))
}

# Show GPU utilization
gpu-util() {
  local gpu_util=$(cat "$GPU_DEVICE/gpu_busy_percent")
  local mem_util=$(cat "$GPU_DEVICE/mem_busy_percent")
  printf "GPU: %3d%% | Memory: %3d%%\n" "$gpu_util" "$mem_util"
}

# Show power consumption
gpu-power() {
  local power=$(cat "$GPU_HWMON/power1_average")
  local power_cap=$(cat "$GPU_HWMON/power1_cap")
  local power_cap_default=$(cat "$GPU_HWMON/power1_cap_default")
  local power_cap_max=$(cat "$GPU_HWMON/power1_cap_max")
  printf "Current: %dW | Limit: %dW | Default: %dW | Max: %dW\n" \
    $((power / 1000000)) \
    $((power_cap / 1000000)) \
    $((power_cap_default / 1000000)) \
    $((power_cap_max / 1000000))
}

# Show clock speeds with all available states
gpu-clocks() {
  echo "GPU Clock States (SCLK):"
  cat "$GPU_DEVICE/pp_dpm_sclk"
  echo ""
  echo "Memory Clock States (MCLK):"
  cat "$GPU_DEVICE/pp_dpm_mclk"
}

# Show detailed VRAM information
gpu-mem() {
  local vram_total=$(cat "$GPU_DEVICE/mem_info_vram_total")
  local vram_used=$(cat "$GPU_DEVICE/mem_info_vram_used")
  local vram_vis_total=$(cat "$GPU_DEVICE/mem_info_vis_vram_total")
  local vram_vis_used=$(cat "$GPU_DEVICE/mem_info_vis_vram_used")
  local gtt_total=$(cat "$GPU_DEVICE/mem_info_gtt_total")
  local gtt_used=$(cat "$GPU_DEVICE/mem_info_gtt_used")

  echo "VRAM (Video RAM):"
  printf "  Total:   %5dMB\n" $((vram_total / 1024 / 1024))
  printf "  Used:    %5dMB (%d%%)\n" \
    $((vram_used / 1024 / 1024)) \
    $((vram_used * 100 / vram_total))
  echo ""
  echo "Visible VRAM (CPU-accessible):"
  printf "  Total:   %5dMB\n" $((vram_vis_total / 1024 / 1024))
  printf "  Used:    %5dMB (%d%%)\n" \
    $((vram_vis_used / 1024 / 1024)) \
    $((vram_vis_used * 100 / vram_vis_total))
  echo ""
  echo "GTT (Graphics Translation Table):"
  printf "  Total:   %5dMB\n" $((gtt_total / 1024 / 1024))
  printf "  Used:    %5dMB (%d%%)\n" \
    $((gtt_used / 1024 / 1024)) \
    $((gtt_used * 100 / gtt_total))
}

# Show fan information and control
gpu-fan() {
  local fan_speed=$(cat "$GPU_HWMON/fan1_input")
  local fan_enable=$(cat "$GPU_HWMON/fan1_enable")
  local fan_max=$(cat "$GPU_HWMON/fan1_max")
  local fan_min=$(cat "$GPU_HWMON/fan1_min")
  local pwm=$(cat "$GPU_HWMON/pwm1")
  local pwm_enable=$(cat "$GPU_HWMON/pwm1_enable")
  local pwm_max=$(cat "$GPU_HWMON/pwm1_max")

  echo "Fan Status:"
  printf "  Speed:   %4d RPM (min: %d, max: %d)\n" "$fan_speed" "$fan_min" "$fan_max"
  printf "  PWM:     %3d / %d (%d%%)\n" "$pwm" "$pwm_max" $((pwm * 100 / pwm_max))

  if [ "$pwm_enable" = "2" ]; then
    echo "  Mode:    Auto (driver controlled)"
  elif [ "$pwm_enable" = "1" ]; then
    echo "  Mode:    Manual"
  else
    echo "  Mode:    Unknown ($pwm_enable)"
  fi

  if [ "$#" -gt 0 ]; then
    case "$1" in
      auto)
        echo "Setting fan to auto mode..."
        echo 2 | sudo tee "$GPU_HWMON/pwm1_enable" >/dev/null
        ;;
      manual)
        if [ "$#" -lt 2 ]; then
          echo "Usage: gpu-fan manual <pwm_value>"
          echo "PWM range: 0-$pwm_max"
        else
          echo "Setting fan to manual mode with PWM=$2..."
          echo 1 | sudo tee "$GPU_HWMON/pwm1_enable" >/dev/null
          echo "$2" | sudo tee "$GPU_HWMON/pwm1" >/dev/null
        fi
        ;;
      *)
        echo "Usage: gpu-fan [auto|manual <pwm_value>]"
        ;;
    esac
  fi
}

# Watch GPU stats in real-time
gpu-watch() {
  watch -n 1 -c "zsh -c 'source $HOME/.config/zsh/gpu.zsh && gpu-status'"
}

# Alias for convenience
alias gpu='gpu-status'
