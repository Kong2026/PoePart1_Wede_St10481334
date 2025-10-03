#!/usr/bin/env bash
set -euo pipefail

# Simple gzip size budget checker for static site
# Budgets in bytes (gzipped)
# Set sensible defaults for small static sites; override via env if needed
BUDGET_HTML=${BUDGET_HTML:-6000}
BUDGET_CSS=${BUDGET_CSS:-1200}

red() { printf "\033[31m%s\033[0m\n" "$*"; }
green() { printf "\033[32m%s\033[0m\n" "$*"; }
yellow() { printf "\033[33m%s\033[0m\n" "$*"; }

fail_count=0

check_file() {
  local file=$1
  local budget=$2
  local kind=$3
  if [[ ! -f "$file" ]]; then return 0; fi
  size=$(gzip -c "$file" | wc -c | tr -d ' ')
  if (( size > budget )); then
    red "FAIL: $file ($kind) gzipped ${size}B > budget ${budget}B"
    fail_count=$((fail_count+1))
  else
    green "OK:   $file ($kind) gzipped ${size}B <= budget ${budget}B"
  fi
}

shopt -s nullglob
for f in ./*.html; do check_file "$f" "$BUDGET_HTML" "html"; done
for f in ./*.css; do check_file "$f" "$BUDGET_CSS" "css"; done

if (( fail_count > 0 )); then
  yellow "\nOne or more files exceed budgets. Adjust content or budgets as needed."
  exit 1
fi

green "\nAll files within gzip budgets."
