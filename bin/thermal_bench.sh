#!/usr/bin/env bash
# thermal_bench — sustained-load thermal + performance snapshot for this laptop.
#
# Purpose: capture a repeatable "before / after" measurement (e.g. before and
# after a thermal-paste re-application at a service center) so you can prove
# whether cooling actually improved. It pins the machine to a fixed power state
# (ASUS Performance profile + performance governor, on AC), cools down, then
# hammers the CPU (and GPU) while logging package temperature, fan RPM and
# clock speed once per sample.
#
# Usage:
#   thermal_bench [OUTDIR]
#     OUTDIR defaults to ./bench-<timestamp>. Run it as e.g.:
#       thermal_bench before     # before service center
#       thermal_bench after      # after  service center
#     then:  thermal_compare before after
#
# Tunables (environment variables, all in seconds unless noted):
#   IDLE_SECS=60     idle baseline sampling window
#   CPU_SECS=480     CPU sustained-load duration (long enough to reach steady state)
#   GPU_SECS=240     GPU sustained-load duration (0 or SKIP_GPU=1 to skip)
#   BENCH_SECS=60    sysbench scoring duration
#   COOL_SECS=45     cooldown before idle baseline and between phases
#   SAMPLE=2         seconds between samples
#   PROFILE=Performance   ASUS platform profile to pin during the test
#   SKIP_GPU=0       set to 1 to skip the GPU stress phase
#
# IMPORTANT for a fair comparison: run BOTH before and after with the laptop
# plugged in, lid open, same surface, similar room temperature, and no other
# heavy programs running. Use the exact same tunables both times.

set -uo pipefail

##############################################################################
# Config
##############################################################################
LABEL_ARG="${1:-}"
OUT="${LABEL_ARG:-bench-$(date +%Y%m%d-%H%M%S)}"
LABEL="$(basename "$OUT")"

IDLE_SECS="${IDLE_SECS:-60}"
CPU_SECS="${CPU_SECS:-480}"
GPU_SECS="${GPU_SECS:-240}"
BENCH_SECS="${BENCH_SECS:-60}"
COOL_SECS="${COOL_SECS:-45}"
SAMPLE="${SAMPLE:-2}"
PROFILE="${PROFILE:-Performance}"
SKIP_GPU="${SKIP_GPU:-0}"

NPROC="$(nproc)"

mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"   # absolute, so cleanup/restore is unaffected by cwd

##############################################################################
# Helpers
##############################################################################
c_reset=$'\033[0m'; c_b=$'\033[1m'; c_g=$'\033[32m'; c_y=$'\033[33m'; c_c=$'\033[36m'

say()  { printf '\n%s== %s ==%s\n' "$c_b$c_c" "$*" "$c_reset"; }
info() { printf '%s%s%s\n' "$c_g" "$*" "$c_reset"; }
warn() { printf '%s%s%s\n' "$c_y" "$*" "$c_reset" >&2; }

# Is value a finite number?
is_num() { [[ "${1:-}" =~ ^-?[0-9]+([.][0-9]+)?$ ]]; }
# Echo number for JSON, or null.
jnum() { if is_num "${1:-}"; then printf '%s' "$1"; else printf 'null'; fi; }

# countdown SECONDS "message"
countdown() {
  local n="$1" msg="$2"
  while [ "$n" -gt 0 ]; do
    printf '\r%s%s %3ds %s' "$c_y" "$msg" "$n" "$c_reset"
    sleep 1; n=$((n-1))
  done
  printf '\r\033[K'
}

# One CPU/sensors sample -> "pkg_temp,max_core,cpu_fan,gpu_fan" (NA where missing).
# Pulls the first *_input field of each sensor so it works regardless of which
# tempN_input/fanN_input index a given chip happens to use.
sample_cpu() {
  sensors -j 2>/dev/null | jq -r '
    def firstinput(f): [ .[] | f | objects | to_entries[] | select(.key|endswith("_input")) | .value ] | map(select(. != null));
    def coremax:       [ .[] | to_entries[] | select(.key|startswith("Core ")) | .value | objects | to_entries[] | select(.key|endswith("_input")) | .value ] | map(select(. != null)) | (max);
    (firstinput(.["Package id 0"]?) | (.[0])) as $pkg  |
    (coremax)                                 as $maxc |
    (firstinput(.cpu_fan?)          | (.[0])) as $cf   |
    (firstinput(.gpu_fan?)          | (.[0])) as $gf   |
    [ ($pkg // $maxc // "NA"), ($maxc // "NA"), ($cf // "NA"), ($gf // "NA") ]
    | map(tostring) | join(",")
  ' 2>/dev/null || echo "NA,NA,NA,NA"
}

# One GPU sample -> "temp,clock_mhz,power_w,util" (NA,NA,NA,NA if no GPU)
sample_gpu() {
  if [ "$HAVE_GPU" = 1 ]; then
    nvidia-smi --query-gpu=temperature.gpu,clocks.current.sm,power.draw,utilization.gpu \
      --format=csv,noheader,nounits 2>/dev/null \
      | sed 's/ //g' | head -n1 || echo "NA,NA,NA,NA"
  else
    echo "NA,NA,NA,NA"
  fi
}

# agg FILE COL MIN_ELAPSED -> "avg max min count"  (COL is 1-based, col1=elapsed_s, skips header)
agg() {
  awk -F, -v c="$2" -v me="${3:-0}" '
    NR==1 { next }
    {
      v=$c
      if (v=="NA" || v=="") next
      if (($1+0) < (me+0)) next
      n++; s+=v
      if (mx=="" || v>mx) mx=v
      if (mn=="" || v<mn) mn=v
    }
    END {
      if (n==0) { print "NA NA NA 0"; exit }
      printf "%.1f %.1f %.1f %d\n", s/n, mx, mn, n
    }' "$1"
}

##############################################################################
# Detect environment
##############################################################################
say "Environment"
HAVE_GPU=0
if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi -L >/dev/null 2>&1; then HAVE_GPU=1; fi
[ "$SKIP_GPU" = 1 ] && HAVE_GPU=0
[ "$GPU_SECS" = 0 ] && HAVE_GPU=0

HAVE_SUDO=0
if sudo -v >/dev/null 2>&1; then HAVE_SUDO=1; fi

KERNEL="$(uname -r)"
HOSTN="$(hostname)"
CPU_MODEL="$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2- | sed 's/^ //')"
AC_ONLINE="$(cat /sys/class/power_supply/A*/online 2>/dev/null | head -n1)"
ORIG_GOV="$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)"
ORIG_PROFILE="$(asusctl profile get 2>/dev/null | awk -F': ' '/Active profile/{print $2; exit}')"
GPU_NAME="NA"; [ "$HAVE_GPU" = 1 ] && GPU_NAME="$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -n1)"

info "Output dir : $OUT  (label: $LABEL)"
info "CPU        : $CPU_MODEL  ($NPROC threads)"
info "GPU        : $GPU_NAME  (stress: $([ "$HAVE_GPU" = 1 ] && echo yes || echo no))"
info "AC online  : ${AC_ONLINE:-unknown}   sudo: $([ "$HAVE_SUDO" = 1 ] && echo yes || echo 'no (turbostat/governor skipped)')"
info "Profile    : $ORIG_PROFILE -> $PROFILE     Governor: $ORIG_GOV -> performance"
EST=$(( COOL_SECS + IDLE_SECS + COOL_SECS + CPU_SECS + BENCH_SECS + 60 ))
[ "$HAVE_GPU" = 1 ] && EST=$(( EST + COOL_SECS + GPU_SECS ))
info "Estimated runtime: ~$(( EST/60 )) min"

if [ "${AC_ONLINE:-0}" != "1" ]; then
  warn "WARNING: laptop does not appear to be on AC power. Plug it in for a valid test."
fi

##############################################################################
# Pin power state (best effort) + cleanup trap
##############################################################################
SUDO_KEEP=""
restore() {
  printf '\n'
  say "Restoring system state"
  if [ "$HAVE_SUDO" = 1 ] && [ -n "$ORIG_GOV" ]; then
    for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
      echo "$ORIG_GOV" | sudo tee "$g" >/dev/null 2>&1 || true
    done
    info "governor restored to $ORIG_GOV"
  fi
  if [ -n "$ORIG_PROFILE" ]; then
    asusctl profile set "$ORIG_PROFILE" >/dev/null 2>&1 || true
    info "ASUS profile restored to $ORIG_PROFILE"
  fi
  [ -n "$SUDO_KEEP" ] && kill "$SUDO_KEEP" >/dev/null 2>&1 || true
}
trap restore EXIT INT TERM

# Keep the sudo timestamp alive for the whole (long) run.
if [ "$HAVE_SUDO" = 1 ]; then
  ( while true; do sudo -n -v >/dev/null 2>&1 || exit; sleep 50; done ) &
  SUDO_KEEP=$!
  for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo performance | sudo tee "$g" >/dev/null 2>&1 || true
  done
fi
asusctl profile set "$PROFILE" >/dev/null 2>&1 || true

##############################################################################
# Phase 1: idle baseline
##############################################################################
say "Phase 1/4 — idle baseline"
countdown "$COOL_SECS" "cooling down before idle baseline..."
echo "elapsed_s,pkg_temp,max_core,cpu_fan,gpu_fan" > "$OUT/idle.csv"
SECONDS=0
while [ "$SECONDS" -lt "$IDLE_SECS" ]; do
  printf '%s,%s\n' "$SECONDS" "$(sample_cpu)" >> "$OUT/idle.csv"
  printf '\r  idle  %3ds/%ds  pkg=%s°C  fan=%s rpm   ' \
    "$SECONDS" "$IDLE_SECS" "$(tail -n1 "$OUT/idle.csv" | cut -d, -f2)" \
    "$(tail -n1 "$OUT/idle.csv" | cut -d, -f4)"
  sleep "$SAMPLE"
done
printf '\r\033[K'
read -r idle_avg _ idle_min _ < <(agg "$OUT/idle.csv" 2 0)
read -r idle_fan_avg _ _ _ < <(agg "$OUT/idle.csv" 4 0)
info "idle pkg temp: avg ${idle_avg}°C  min ${idle_min}°C   cpu fan avg ${idle_fan_avg} rpm"

##############################################################################
# Phase 2: CPU sustained load
##############################################################################
say "Phase 2/4 — CPU sustained load (${CPU_SECS}s, $NPROC threads, stress-ng)"
countdown "$COOL_SECS" "cooling down before CPU load..."

# turbostat logger (clocks/power/throttle) — needs root, best effort.
TS_PID=""
if [ "$HAVE_SUDO" = 1 ]; then
  iters=$(( CPU_SECS / SAMPLE + 2 ))
  sudo turbostat --quiet --interval "$SAMPLE" --num_iterations "$iters" \
    --show Core,Bzy_MHz,PkgTmp,PkgWatt,Busy% > "$OUT/turbostat_raw.txt" 2>&1 &
  TS_PID=$!
fi

# YAML metrics (-Y) give stable named keys, unlike the positional --metrics table.
stress-ng --cpu "$NPROC" --timeout "${CPU_SECS}s" --metrics -Y "$OUT/stressng.yaml" \
  > "$OUT/stressng.txt" 2>&1 &
STRESS_PID=$!

echo "elapsed_s,pkg_temp,max_core,cpu_fan,gpu_fan" > "$OUT/cpu_load.csv"
SECONDS=0
while kill -0 "$STRESS_PID" 2>/dev/null && [ "$SECONDS" -lt "$((CPU_SECS + 10))" ]; do
  printf '%s,%s\n' "$SECONDS" "$(sample_cpu)" >> "$OUT/cpu_load.csv"
  line="$(tail -n1 "$OUT/cpu_load.csv")"
  printf '\r  load  %3ds/%ds  pkg=%s°C  fan=%s rpm   ' \
    "$SECONDS" "$CPU_SECS" "$(echo "$line" | cut -d, -f2)" "$(echo "$line" | cut -d, -f4)"
  sleep "$SAMPLE"
done
printf '\r\033[K'
wait "$STRESS_PID" 2>/dev/null || true
[ -n "$TS_PID" ] && wait "$TS_PID" 2>/dev/null || true

# Parse turbostat summary rows -> freq.csv (idx,bzy_mhz,pkgtmp,pkgwatt), skip first (since-boot) row.
if [ -s "$OUT/turbostat_raw.txt" ]; then
  awk '
    /Bzy_MHz/ && /PkgWatt/ { for (i=1;i<=NF;i++) h[$i]=i; have=1; next }
    have && $1=="-" {
      seen++; if (seen==1) next   # drop first summary (since boot)
      printf "%d,%s,%s,%s\n", seen, $(h["Bzy_MHz"]), $(h["PkgTmp"]), $(h["PkgWatt"])
    }
  ' "$OUT/turbostat_raw.txt" > "$OUT/freq.csv" 2>/dev/null || true
  if [ -s "$OUT/freq.csv" ]; then sed -i '1i idx,bzy_mhz,pkg_tmp,pkg_watt' "$OUT/freq.csv"; fi
fi

# steady-state window = last 2 min (or second half for short runs)
if [ "$CPU_SECS" -gt 180 ]; then cpu_steady_start=$((CPU_SECS-120)); else cpu_steady_start=$((CPU_SECS/2)); fi
read -r cpu_avg cpu_peak _ _        < <(agg "$OUT/cpu_load.csv" 2 0)
read -r cpu_steady _ _ _            < <(agg "$OUT/cpu_load.csv" 2 "$cpu_steady_start")
read -r cpu_fan_steady cpu_fan_peak _ _ < <(agg "$OUT/cpu_load.csv" 4 "$cpu_steady_start")

bzy_steady=NA; pkgwatt_steady=NA; pkgtmp_peak=NA
if [ -s "$OUT/freq.csv" ]; then
  rows=$(($(wc -l < "$OUT/freq.csv") - 1)); half=$(( rows/2 )); [ "$half" -lt 1 ] && half=0
  read -r bzy_steady _ _ _      < <(agg "$OUT/freq.csv" 2 "$half")
  read -r _ pkgtmp_peak _ _     < <(agg "$OUT/freq.csv" 3 0)
  read -r pkgwatt_steady _ _ _  < <(agg "$OUT/freq.csv" 4 "$half")
fi
info "CPU load: peak ${cpu_peak}°C  steady ${cpu_steady}°C  steady fan ${cpu_fan_steady} rpm  steady clock ${bzy_steady} MHz  pkg ${pkgwatt_steady} W"

##############################################################################
# Phase 3: CPU benchmark scores (performance — throttling lowers these)
##############################################################################
say "Phase 3/4 — CPU benchmark scores"
sysbench_eps=NA
if command -v sysbench >/dev/null 2>&1; then
  info "sysbench cpu (${BENCH_SECS}s, $NPROC threads)..."
  sysbench cpu --threads="$NPROC" --cpu-max-prime=20000 --time="$BENCH_SECS" run \
    > "$OUT/sysbench.txt" 2>&1 || true
  sysbench_eps="$(awk -F: '/events per second/{gsub(/ /,"",$2); print $2}' "$OUT/sysbench.txt")"
  [ -z "$sysbench_eps" ] && sysbench_eps=NA
  info "sysbench events/sec: $sysbench_eps"
fi

stressng_bogo="$(awk -F': ' '/bogo-ops-per-second-real-time/{print $2; exit}' "$OUT/stressng.yaml" 2>/dev/null)"
[ -z "$stressng_bogo" ] && stressng_bogo=NA

p7zip_mips=NA
if command -v 7z >/dev/null 2>&1; then
  info "7-zip benchmark..."
  7z b -mmt"$NPROC" > "$OUT/sevenzip.txt" 2>&1 || true
  p7zip_mips="$(awk '/^Tot:/{print $NF}' "$OUT/sevenzip.txt" | tail -n1)"
  [ -z "$p7zip_mips" ] && p7zip_mips=NA
  info "7-zip total rating (MIPS): $p7zip_mips"
fi

##############################################################################
# Phase 4: GPU sustained load
##############################################################################
gpu_peak=NA; gpu_steady=NA; gpu_clock_steady=NA; gpu_power_steady=NA; gpu_fan_steady=NA
if [ "$HAVE_GPU" = 1 ]; then
  say "Phase 4/4 — GPU sustained load (${GPU_SECS}s, gpu-burn)"
  countdown "$COOL_SECS" "cooling down before GPU load..."
  if command -v gpu-burn >/dev/null 2>&1; then
    gpu-burn "$GPU_SECS" > "$OUT/gpuburn.txt" 2>&1 &
    GPU_PID=$!
  else
    warn "gpu-burn not found; logging GPU temps without an extra stressor."
    GPU_PID=""
  fi
  echo "elapsed_s,gpu_temp,gpu_clock,gpu_power,gpu_util,gpu_fan" > "$OUT/gpu_load.csv"
  SECONDS=0
  while [ "$SECONDS" -lt "$GPU_SECS" ]; do
    g="$(sample_gpu)"
    gfan="$(sample_cpu | cut -d, -f4)"   # gpu_fan is field 4 of sample_cpu
    printf '%s,%s,%s\n' "$SECONDS" "$g" "$gfan" >> "$OUT/gpu_load.csv"
    printf '\r  gpu   %3ds/%ds  temp=%s°C  clock=%s MHz   ' \
      "$SECONDS" "$GPU_SECS" "$(echo "$g" | cut -d, -f1)" "$(echo "$g" | cut -d, -f2)"
    sleep "$SAMPLE"
    [ -n "$GPU_PID" ] && ! kill -0 "$GPU_PID" 2>/dev/null && break
  done
  printf '\r\033[K'
  [ -n "$GPU_PID" ] && wait "$GPU_PID" 2>/dev/null || true

  if [ "$GPU_SECS" -gt 120 ]; then gpu_steady_start=$((GPU_SECS-60)); else gpu_steady_start=$((GPU_SECS/2)); fi
  read -r _ gpu_peak _ _          < <(agg "$OUT/gpu_load.csv" 2 0)
  read -r gpu_steady _ _ _        < <(agg "$OUT/gpu_load.csv" 2 "$gpu_steady_start")
  read -r gpu_clock_steady _ _ _  < <(agg "$OUT/gpu_load.csv" 3 "$gpu_steady_start")
  read -r gpu_power_steady _ _ _  < <(agg "$OUT/gpu_load.csv" 4 "$gpu_steady_start")
  read -r gpu_fan_steady _ _ _    < <(agg "$OUT/gpu_load.csv" 6 "$gpu_steady_start")
  info "GPU load: peak ${gpu_peak}°C  steady ${gpu_steady}°C  steady clock ${gpu_clock_steady} MHz  pkg ${gpu_power_steady} W"
else
  say "Phase 4/4 — GPU sustained load (skipped)"
fi

##############################################################################
# Write metadata + machine-readable summary
##############################################################################
TS="$(date -Iseconds)"
{
  echo "label:        $LABEL"
  echo "timestamp:    $TS"
  echo "host:         $HOSTN"
  echo "kernel:       $KERNEL"
  echo "cpu:          $CPU_MODEL ($NPROC threads)"
  echo "gpu:          $GPU_NAME"
  echo "ac_online:    ${AC_ONLINE:-unknown}"
  echo "asus_profile: $PROFILE (was $ORIG_PROFILE)"
  echo "governor:     performance (was $ORIG_GOV)"
  echo "durations:    idle=${IDLE_SECS}s cpu=${CPU_SECS}s gpu=${GPU_SECS}s bench=${BENCH_SECS}s sample=${SAMPLE}s"
  echo
  echo "NOTE: record the room/ambient temperature for this run so before/after"
  echo "      are comparable. Ambient: ____ °C"
} > "$OUT/meta.txt"

jq -n \
  --arg label "$LABEL" --arg ts "$TS" --arg host "$HOSTN" --arg kernel "$KERNEL" \
  --arg cpu "$CPU_MODEL" --arg gpu "$GPU_NAME" --arg profile "$PROFILE" \
  --argjson idle_avg "$(jnum "$idle_avg")" --argjson idle_min "$(jnum "$idle_min")" --argjson idle_fan "$(jnum "$idle_fan_avg")" \
  --argjson cpu_avg "$(jnum "$cpu_avg")" --argjson cpu_peak "$(jnum "$cpu_peak")" --argjson cpu_steady "$(jnum "$cpu_steady")" \
  --argjson cpu_fan_steady "$(jnum "$cpu_fan_steady")" --argjson cpu_fan_peak "$(jnum "$cpu_fan_peak")" \
  --argjson bzy_steady "$(jnum "$bzy_steady")" --argjson pkgwatt_steady "$(jnum "$pkgwatt_steady")" --argjson pkgtmp_peak "$(jnum "$pkgtmp_peak")" \
  --argjson sysbench "$(jnum "$sysbench_eps")" --argjson stressng "$(jnum "$stressng_bogo")" --argjson p7zip "$(jnum "$p7zip_mips")" \
  --argjson gpu_peak "$(jnum "$gpu_peak")" --argjson gpu_steady "$(jnum "$gpu_steady")" \
  --argjson gpu_clock "$(jnum "$gpu_clock_steady")" --argjson gpu_power "$(jnum "$gpu_power_steady")" --argjson gpu_fan "$(jnum "$gpu_fan_steady")" \
  '{
     label:$label, timestamp:$ts, host:$host, kernel:$kernel, cpu:$cpu, gpu:$gpu, profile:$profile,
     idle:        { pkg_temp_avg:$idle_avg, pkg_temp_min:$idle_min, cpu_fan_avg:$idle_fan },
     cpu_load:    { pkg_temp_avg:$cpu_avg, pkg_temp_peak:$cpu_peak, pkg_temp_steady:$cpu_steady,
                    cpu_fan_steady:$cpu_fan_steady, cpu_fan_peak:$cpu_fan_peak,
                    bzy_mhz_steady:$bzy_steady, pkg_watt_steady:$pkgwatt_steady, pkg_tmp_peak_turbostat:$pkgtmp_peak },
     scores:      { sysbench_eps:$sysbench, stressng_bogo_ops_s:$stressng, p7zip_mips:$p7zip },
     gpu_load:    { temp_peak:$gpu_peak, temp_steady:$gpu_steady, clock_mhz_steady:$gpu_clock,
                    power_w_steady:$gpu_power, fan_steady:$gpu_fan }
   }' > "$OUT/summary.json"

##############################################################################
# Human-readable combined report
##############################################################################
{
  echo "# Thermal / performance benchmark — $LABEL"
  echo
  echo "- When: $TS"
  echo "- Host: $HOSTN ($KERNEL)"
  echo "- CPU:  $CPU_MODEL ($NPROC threads)"
  echo "- GPU:  $GPU_NAME"
  echo "- Pinned: ASUS profile **$PROFILE**, governor **performance**, AC=${AC_ONLINE:-?}"
  echo
  echo "## Key metrics"
  echo
  echo "| Metric | Value | Better when |"
  echo "|---|---|---|"
  echo "| Idle pkg temp (avg) | ${idle_avg} °C | lower |"
  echo "| Idle pkg temp (min) | ${idle_min} °C | lower |"
  echo "| CPU load steady temp | ${cpu_steady} °C | lower |"
  echo "| CPU load peak temp | ${cpu_peak} °C | lower |"
  echo "| CPU steady clock | ${bzy_steady} MHz | higher |"
  echo "| CPU steady package power | ${pkgwatt_steady} W | higher (more sustained budget) |"
  echo "| CPU steady fan | ${cpu_fan_steady} rpm | (context) |"
  echo "| sysbench events/sec | ${sysbench_eps} | higher |"
  echo "| stress-ng bogo ops/s | ${stressng_bogo} | higher |"
  echo "| 7-zip total MIPS | ${p7zip_mips} | higher |"
  echo "| GPU load steady temp | ${gpu_steady} °C | lower |"
  echo "| GPU load peak temp | ${gpu_peak} °C | lower |"
  echo "| GPU steady clock | ${gpu_clock_steady} MHz | higher |"
  echo
  echo "## How to read it"
  echo
  echo "After re-pasting, you want: **lower steady/peak temps**, and/or **higher"
  echo "sustained clocks and benchmark scores** at the same temps (less thermal"
  echo "throttling). Compare two runs with: \`thermal_compare before after\`."
  echo
  echo "Raw logs in this folder: idle.csv, cpu_load.csv, gpu_load.csv, freq.csv,"
  echo "stressng.txt, stressng.yaml, sysbench.txt, sevenzip.txt, gpuburn.txt,"
  echo "turbostat_raw.txt."
} > "$OUT/summary.md"

say "Done"
info "Results written to: $OUT"
echo
cat "$OUT/summary.md"
