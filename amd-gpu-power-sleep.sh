#!/bin/bash
#
# systemd script to save and restore AMD GPU power_dpm_force_performance_level
#
# This script is designed to work with systemd's sleep/wake hooks.
# It saves the current GPU power mode before the system goes to sleep
# and restores it after the system wakes up.
#
# IMPORTANT:
# -  This script must be executable and placed in /lib/systemd/system-sleep/
#
# Example Usage:
# Place it in the correct directory: sudo cp amd-gpu-power-sleep.sh /lib/systemd/system-sleep/

GPU_POWER_PATH="/sys/devices/pci0000:00/0000:00:08.1/0000:c4:00.0/power_dpm_force_performance_level"
SAVE_FILE="/var/tmp/gpu_power_mode.save"  # Path to the file where we'll save the mode

# Function to save the GPU power mode
save_gpu_mode() {
  if [ -r "$GPU_POWER_PATH" ]; then
    SAVED_MODE=$(cat "$GPU_POWER_PATH")
    echo "Saved GPU power mode: '$SAVED_MODE' to '$SAVE_FILE'"
    echo "$SAVED_MODE" > "$SAVE_FILE" # Save to file
  else
    echo "Error: Cannot read GPU power mode from '$GPU_POWER_PATH'"
    # Do NOT exit here. If we can't save, we still want to try to restore.
    SAVED_MODE="" # Clear it.
  fi
}

# Function to restore the GPU power mode
restore_gpu_mode() {
  if [ -r "$SAVE_FILE" ]; then
    SAVED_MODE=$(cat "$SAVE_FILE")
    echo "Restoring GPU power mode from '$SAVE_FILE' to '$GPU_POWER_PATH'"
    if [ -w "$GPU_POWER_PATH" ]; then
      echo '$SAVED_MODE' > '$GPU_POWER_PATH'
      rm -f "$SAVE_FILE" #remove the file after a successful restore
    else
       echo "Error: Cannot write to GPU power mode path '$GPU_POWER_PATH'"
       exit 1
    fi
  else
    echo "Warning: No saved GPU power mode found at '$SAVE_FILE'. Restoring may not be possible."
  fi
}

main_systemd()
{
  case "$1/$2" in
  pre/*)
    save_gpu_mode
    ;;
  post/*)
    restore_gpu_mode
    ;;
  esac
}

main_pm()
{
  case "$1" in
    suspend|hibernate)
      save_gpu_mode
      ;;
    resume|thaw)
      restore_gpu_mode
      ;;
  esac
  true
}

DIR="$(cd $(dirname "$0") && pwd)"

if [[ "$DIR" =~ "systemd" ]]; then
  main_systemd "$@"
else
  main_pm "$@"
fi

exit 0
