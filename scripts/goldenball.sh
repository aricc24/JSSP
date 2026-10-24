#!/usr/bin/env bash
set -euo pipefail

CONFIG="${1:-config/experiment.conf}"
# shellcheck disable=SC1090
source "$CONFIG"

BIN=./src/main
LOGDIR=logs
mkdir -p "$LOGDIR"

runsPerProcess=$(( TOTAL_RUNS / PROCESSES ))
extra=$(( TOTAL_RUNS % PROCESSES ))

pids=()
for (( i=0; i<PROCESSES; i++ )); do
  myRuns=$runsPerProcess
  if (( i < extra )); then
    myRuns=$(( myRuns + 1 ))
  fi
  seed=$(( BASE_SEED + i * runsPerProcess + (i < extra ? i : extra) ))

  "$BIN" \
    --instance:"$INSTANCE" \
    --runs:"$myRuns" \
    --seed:"$seed" \
    --process:"$i" \
    --num-teams:"$NUM_TEAMS" \
    --players-per-team:"$PLAYERS_PER_TEAM" \
    --max-seasons:"$MAX_SEASONS" \
    --max-training-failures:"$MAX_TRAINING_FAILURES" \
    --custom-training-after:"$CUSTOM_TRAINING_AFTER" \
    --special-transfer-after:"$SPECIAL_TRANSFER_AFTER" \
    > "$LOGDIR/process_${i}.log" 2>&1 &

  pids+=($!)
  echo "Launched process $i (pid ${pids[-1]}, seed $seed, runs $myRuns)"
done

for pid in "${pids[@]}"; do
  wait "$pid"
done

echo
echo "=========================================="
echo " All processes finished — results per log"
echo "=========================================="
for (( i=0; i<PROCESSES; i++ )); do
  echo
  echo "--- logs/process_${i}.log ---"
  tail -n 12 "$LOGDIR/process_${i}.log"
done