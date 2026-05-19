#!/usr/bin/env bash
#
# build_scoreboard.sh — emit a markdown scoreboard from per-server result
# files in a results directory.
#
# Usage: build_scoreboard.sh <results-dir>
#
# Expects one file per server in <results-dir>, named <server>.txt, each
# containing the http11test runner output. The reference 8 are:
# nginx, apache, caddy, bandit, cowboy, lighttpd, haproxy, hyper.
# Stallion is the primary target.
#
# A test ID counts as CORE if every reference server passes it (no FAIL
# in any of the 8 reference result files). The CORE list is the minimum
# compliance bar.

set -euo pipefail

results_dir="${1:-results}"
if [[ ! -d "$results_dir" ]]; then
  echo "error: results dir not found: $results_dir" >&2
  exit 1
fi

ref_servers=(nginx apache caddy bandit cowboy lighttpd haproxy hyper)
all_servers=("${ref_servers[@]}" stallion)

# Sanity: every server must have a result file.
for name in "${all_servers[@]}"; do
  f="$results_dir/$name.txt"
  if [[ ! -f "$f" ]]; then
    echo "error: missing result file: $f" >&2
    exit 1
  fi
done

# Collect all observed test IDs.
all_test_ids=$(
  cat "$results_dir"/*.txt \
  | grep -E "^(PASS|FAIL|SKIP) " \
  | awk '{print $2}' \
  | sed 's/:$//' \
  | sort -u
)

# Classify each test as CORE (no FAIL across reference 8) or divergent.
core_tids=()
divergent_tids=()
for tid in $all_test_ids; do
  has_fail=0
  for name in "${ref_servers[@]}"; do
    if grep -q "^FAIL $tid:" "$results_dir/$name.txt"; then
      has_fail=1
      break
    fi
  done
  if [[ "$has_fail" -eq 0 ]]; then
    core_tids+=("$tid")
  else
    divergent_tids+=("$tid")
  fi
done

ts=$(date -u +%Y-%m-%dT%H%M%SZ)
total_tests=$(echo "$all_test_ids" | wc -l | tr -d ' ')

emit_row() {
  local tid="$1"
  local row="| \`$tid\` |"
  for name in "${all_servers[@]}"; do
    local f="$results_dir/$name.txt"
    if grep -q "^PASS $tid\$" "$f"; then
      row="$row P |"
    elif grep -q "^SKIP $tid:" "$f"; then
      row="$row S |"
    elif grep -q "^FAIL $tid:" "$f"; then
      row="$row **F** |"
    else
      row="$row ? |"
    fi
  done
  echo "$row"
}

cat <<EOF
# http11test scoreboard — ${ts}

${#all_servers[@]} servers × ${total_tests} tests.

**Legend:** P = pass · **F** = fail (bold) · S = skip (test inapplicable)

## CORE tests

Universal-PASS across the reference 8-server set. Stallion column shows where it stands against the minimum bar.

| Test ID | nginx | apache | caddy | bandit | cowboy | lighttpd | haproxy | hyper | **stallion** |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
EOF

for tid in "${core_tids[@]}"; do
  emit_row "$tid"
done

cat <<EOF

## Divergent tests

Already split across the reference 8 — each is its own dialect decision.

| Test ID | nginx | apache | caddy | bandit | cowboy | lighttpd | haproxy | hyper | **stallion** |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
EOF

for tid in "${divergent_tids[@]}"; do
  emit_row "$tid"
done

cat <<EOF

## Scores

| Server | Pass | Fail | Skip |
|---|---:|---:|---:|
EOF

for name in "${all_servers[@]}"; do
  f="$results_dir/$name.txt"
  p=$(grep -c "^PASS " "$f" || true)
  fl=$(grep -c "^FAIL " "$f" || true)
  s=$(grep -c "^SKIP " "$f" || true)
  echo "| $name | $p | $fl | $s |"
done
