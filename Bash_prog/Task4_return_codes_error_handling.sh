#!/usr/bin/env bash
# ---------------------------------------------------
# @title       Task4_return_codes_error_handling.sh
# @author      Joseph Ayofolaji Oluwamuyiwa
# @index       5230160112
# @school      University of Skilled Training and Entrepreneurial Development (USTED)
# @description Runs a set of system health checks, using $? and a trap for
#              cleanup, with a custom exit code scheme.
# @date        14-09-2026
# ---------------------------------------------------
#
# Exit code scheme:
#   0 = all checks passed
#   1 = missing/invalid argument
#   2 = one or more checks failed
#   3 = unexpected internal error

usage() {
    echo "Usage: $0 <host-to-ping>"
    echo "  <host-to-ping>  hostname or IP to test reachability against"
    exit 1
}

if [ $# -ne 1 ] || [ -z "$1" ]; then
    usage
fi

HOST="$1"
TMP_FILE=$(mktemp /tmp/task4_check.XXXXXX)
FAILED=0

# --- Cleanup on exit, failure, or Ctrl+C ---
cleanup() {
    rm -f "$TMP_FILE"
    echo "Cleaned up temporary files."
}
trap cleanup EXIT INT TERM

# --- Helper: report pass/fail based on the last command's $? ---
check_status() {
    local description="$1"
    local status="$2"
    if [ "$status" -eq 0 ]; then
        echo "[PASS] $description"
    else
        echo "[FAIL] $description" >&2
        FAILED=1
    fi
}

echo "Running system checks..."
echo ""

# Check 1: host reachable
ping -c 1 -W 2 "$HOST" > "$TMP_FILE" 2>&1
check_status "Host '$HOST' is reachable" "$?"

# Check 2: disk space usage under 90% on root filesystem
DISK_USAGE=$(df / | awk 'NR==2 {gsub("%","",$5); print $5}')
if [ "$DISK_USAGE" -lt 90 ]; then
    check_status "Disk usage is under 90% (currently ${DISK_USAGE}%)" 0
else
    check_status "Disk usage is under 90% (currently ${DISK_USAGE}%)" 1
fi

# Check 3: a known file exists and is readable
[ -r "/etc/hostname" ]
check_status "File /etc/hostname exists and is readable" "$?"

# Check 4: a common command is installed
command -v bash > /dev/null 2>&1
check_status "Command 'bash' is installed" "$?"

echo ""
if [ "$FAILED" -eq 0 ]; then
    echo "All checks passed."
    exit 0
else
    echo "One or more checks failed." >&2
    exit 2
fi
