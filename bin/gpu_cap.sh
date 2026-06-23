#!/usr/bin/env bash
# gpu_cap — cap the dGPU max graphics clock so it runs cooler & quieter during
# games / CUDA. The RTX 3050 Ti boosts to 2100 MHz; capping lops off the hot,
# loud top of the voltage-frequency curve (power scales super-linearly up there).
#
# Run it before a gaming/CUDA session; `off` restores defaults and lets the
# dGPU sleep again (so your battery/idle isn't penalised the rest of the time).
#
# Usage:
#   gpu_cap on  [MHZ]    cap max graphics clock (default 1200 MHz)
#   gpu_cap off          release the cap, restore default clocks, allow sleep
#   gpu_cap status       show current clock / temp / power
#
# Guide values for this card: ~1500 = mild, 1200 = balanced, 1000 = quietest.
# Needs sudo (nvidia-smi clock control is privileged).

set -uo pipefail

cmd="${1:-status}"
mhz="${2:-1200}"

command -v nvidia-smi >/dev/null 2>&1 || { echo "nvidia-smi not found"; exit 1; }
nvidia-smi -L >/dev/null 2>&1 || { echo "no NVIDIA GPU available"; exit 1; }

show() {
  echo
  nvidia-smi --query-gpu=name,clocks.gr,clocks.max.gr,temperature.gpu,power.draw \
    --format=csv 2>/dev/null
}

case "$cmd" in
  on)
    if ! [[ "$mhz" =~ ^[0-9]+$ ]]; then echo "MHZ must be a number"; exit 2; fi
    echo "Capping GPU graphics clock to ${mhz} MHz (persistence on)..."
    # Persistence mode keeps the driver/GPU resident so the lock sticks for the
    # session. `off` turns it back off so the dGPU can power down afterwards.
    sudo nvidia-smi -pm 1 >/dev/null
    sudo nvidia-smi -lgc "0,${mhz}"
    show
    echo
    echo "Tip: verify under load — run a game/gpu_burn and watch clocks.gr stay <= ${mhz}."
    ;;
  off)
    echo "Releasing GPU clock cap and restoring defaults..."
    sudo nvidia-smi -rgc
    sudo nvidia-smi -pm 0 >/dev/null
    show
    ;;
  status)
    show
    ;;
  *)
    echo "usage: gpu_cap [on [MHZ] | off | status]"; exit 2 ;;
esac
