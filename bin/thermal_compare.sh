#!/usr/bin/env bash
# thermal_compare — diff two thermal_bench runs and say whether cooling improved.
#
# Usage:  thermal_compare BEFORE_DIR AFTER_DIR
#   e.g.  thermal_compare before after
#
# Reads summary.json from each directory and prints a side-by-side table with
# the delta and a verdict per metric (temps: lower is better; clocks/scores:
# higher is better).

set -uo pipefail

if [ $# -lt 2 ]; then
  echo "usage: thermal_compare BEFORE_DIR AFTER_DIR" >&2
  exit 2
fi

B="$1/summary.json"
A="$2/summary.json"
for f in "$B" "$A"; do
  [ -f "$f" ] || { echo "error: $f not found (run thermal_bench there first)" >&2; exit 1; }
done

c_reset=$'\033[0m'; c_b=$'\033[1m'; c_g=$'\033[32m'; c_r=$'\033[31m'; c_d=$'\033[2m'

bl="$(jq -r '.label' "$B")"
al="$(jq -r '.label' "$A")"

printf '%s%s vs %s%s\n' "$c_b" "$bl" "$al" "$c_reset"
printf '%s%s%s\n' "$c_d" "$(jq -r '"before: \(.timestamp)  \(.cpu)"' "$B")" "$c_reset"
printf '%s%s%s\n\n' "$c_d" "$(jq -r '"after : \(.timestamp)  \(.cpu)"' "$A")" "$c_reset"

printf '%-26s %10s %10s %10s   %s\n' "metric" "$bl" "$al" "delta" "verdict"
printf '%s\n' "----------------------------------------------------------------------------"

# row "Label" jq-path direction unit
# direction: lower | higher | info
row() {
  local name="$1" path="$2" dir="$3" unit="${4:-}"
  local bv av delta verdict color
  bv="$(jq -r "$path // \"NA\"" "$B")"
  av="$(jq -r "$path // \"NA\"" "$A")"

  if [ "$bv" = "NA" ] || [ "$av" = "NA" ]; then
    printf '%-26s %10s %10s %10s   %s\n' "$name" "$bv" "$av" "-" "n/a"
    return
  fi

  delta="$(awk -v a="$av" -v b="$bv" 'BEGIN{printf "%+.1f", a-b}')"
  local pct
  pct="$(awk -v a="$av" -v b="$bv" 'BEGIN{ if(b==0){print "—"} else {printf "%+.1f%%", (a-b)/b*100} }')"

  verdict="~ same"; color="$c_d"
  local improved
  improved="$(awk -v a="$av" -v b="$bv" -v d="$dir" 'BEGIN{
    diff=a-b; tol=(b!=0)?(b*0.01):0.5;       # 1% (or 0.5 abs) dead-band
    if (diff<=tol && diff>=-tol) { print "same"; exit }
    if (d=="lower")  { print (diff<0)?"better":"worse" }
    else if (d=="higher") { print (diff>0)?"better":"worse" }
    else print "info"
  }')"
  case "$improved" in
    better) verdict="IMPROVED"; color="$c_g" ;;
    worse)  verdict="regressed"; color="$c_r" ;;
    info)   verdict="(info)";    color="$c_d" ;;
    same)   verdict="~ same";    color="$c_d" ;;
  esac

  printf '%-26s %10s %10s %s%10s%s   %s%-9s%s %s\n' \
    "$name" "$bv$unit" "$av$unit" "$color" "$delta" "$c_reset" "$color" "$verdict" "$c_reset" "$c_d$pct$c_reset"
}

row "idle temp avg (°C)"      ".idle.pkg_temp_avg"        lower
row "idle temp min (°C)"      ".idle.pkg_temp_min"        lower
row "CPU steady temp (°C)"    ".cpu_load.pkg_temp_steady" lower
row "CPU peak temp (°C)"      ".cpu_load.pkg_temp_peak"   lower
row "CPU steady clock (MHz)"  ".cpu_load.bzy_mhz_steady"  higher
row "CPU steady power (W)"    ".cpu_load.pkg_watt_steady" higher
row "CPU steady fan (rpm)"    ".cpu_load.cpu_fan_steady"  info
row "sysbench events/sec"     ".scores.sysbench_eps"      higher
row "stress-ng bogo ops/s"    ".scores.stressng_bogo_ops_s" higher
row "7-zip total MIPS"        ".scores.p7zip_mips"        higher
row "GPU steady temp (°C)"    ".gpu_load.temp_steady"     lower
row "GPU peak temp (°C)"      ".gpu_load.temp_peak"       lower
row "GPU steady clock (MHz)"  ".gpu_load.clock_mhz_steady" higher

echo
echo "${c_d}Interpretation: re-pasting helped if steady/peak temps drop, and/or"
echo "sustained clocks & scores rise (less thermal throttling). Make sure both"
echo "runs used the same profile, AC power, and similar room temperature.${c_reset}"
