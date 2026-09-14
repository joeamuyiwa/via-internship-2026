#!/usr/bin/env bash
# ---------------------------------------------------
# @title       Task3_pipes_redirection.sh
# @author      Joseph Ayofolaji Oluwamuyiwa
# @index       5230160112
# @school      University of Skilled Training and Entrepreneurial Development (USTED)
# @description Generates fake log data, then analyzes it using pipes and
#              text-processing tools, writing results and errors separately.
# @date        14-09-2026
# ---------------------------------------------------

usage() {
    echo "Usage: $0"
    echo "  Generates log data and analyzes it. Takes no arguments."
    exit 1
}

if [ $# -ne 0 ]; then
    usage
fi

LOG_FILE="app.log"
RESULTS_FILE="results.txt"
ERRORS_FILE="errors.log"

# --- Step 1: generate fake log data (50+ lines) via heredoc ---
cat > "$LOG_FILE" << 'EOF'
2026-09-11 10:00:01 INFO 192.168.1.10 User login successful
2026-09-11 10:00:05 INFO 192.168.1.11 User login successful
2026-09-11 10:00:09 WARN 192.168.1.10 Slow response time
2026-09-11 10:00:14 ERROR 192.168.1.12 Database connection failed
2026-09-11 10:00:20 INFO 192.168.1.13 User login successful
2026-09-11 10:00:25 INFO 192.168.1.10 File uploaded
2026-09-11 10:00:30 ERROR 192.168.1.14 Authentication failed
2026-09-11 10:00:35 INFO 192.168.1.11 User logout
2026-09-11 10:00:40 WARN 192.168.1.15 High memory usage
2026-09-11 10:00:45 INFO 192.168.1.10 User login successful
2026-09-11 10:00:50 ERROR 192.168.1.12 Database connection failed
2026-09-11 10:00:55 INFO 192.168.1.16 User login successful
2026-09-11 10:01:00 INFO 192.168.1.10 File downloaded
2026-09-11 10:01:05 WARN 192.168.1.17 Slow response time
2026-09-11 10:01:10 INFO 192.168.1.11 User login successful
2026-09-11 10:01:15 ERROR 192.168.1.18 Authentication failed
2026-09-11 10:01:20 INFO 192.168.1.10 User logout
2026-09-11 10:01:25 INFO 192.168.1.13 User login successful
2026-09-11 10:01:30 WARN 192.168.1.19 High CPU usage
2026-09-11 10:01:35 INFO 192.168.1.10 User login successful
2026-09-11 10:01:40 ERROR 192.168.1.12 Database connection failed
2026-09-11 10:01:45 INFO 192.168.1.11 File uploaded
2026-09-11 10:01:50 INFO 192.168.1.20 User login successful
2026-09-11 10:01:55 WARN 192.168.1.10 Slow response time
2026-09-11 10:02:00 INFO 192.168.1.13 User logout
2026-09-11 10:02:05 ERROR 192.168.1.21 Authentication failed
2026-09-11 10:02:10 INFO 192.168.1.10 User login successful
2026-09-11 10:02:15 INFO 192.168.1.11 User login successful
2026-09-11 10:02:20 WARN 192.168.1.22 High memory usage
2026-09-11 10:02:25 INFO 192.168.1.10 File uploaded
2026-09-11 10:02:30 ERROR 192.168.1.12 Database connection failed
2026-09-11 10:02:35 INFO 192.168.1.23 User login successful
2026-09-11 10:02:40 INFO 192.168.1.10 User logout
2026-09-11 10:02:45 WARN 192.168.1.24 Slow response time
2026-09-11 10:02:50 INFO 192.168.1.11 User login successful
2026-09-11 10:02:55 ERROR 192.168.1.25 Authentication failed
2026-09-11 10:03:00 INFO 192.168.1.10 User login successful
2026-09-11 10:03:05 INFO 192.168.1.13 File downloaded
2026-09-11 10:03:10 WARN 192.168.1.10 High CPU usage
2026-09-11 10:03:15 INFO 192.168.1.11 User logout
2026-09-11 10:03:20 ERROR 192.168.1.12 Database connection failed
2026-09-11 10:03:21 INFO 192.168.1.10 User login successful
2026-09-11 10:03:25 INFO 192.168.1.26 User login successful
2026-09-11 10:03:30 WARN 192.168.1.27 Slow response time
2026-09-11 10:03:35 INFO 192.168.1.10 File uploaded
2026-09-11 10:03:40 ERROR 192.168.1.12 Database connection failed
2026-09-11 10:03:45 INFO 192.168.1.11 User login successful
2026-09-11 10:03:50 INFO 192.168.1.10 User logout
2026-09-11 10:03:55 WARN 192.168.1.28 High memory usage
2026-09-11 10:04:00 INFO 192.168.1.13 User login successful
2026-09-11 10:04:05 ERROR 192.168.1.29 Authentication failed
2026-09-11 10:04:10 INFO 192.168.1.10 User login successful
EOF

if [ $? -eq 0 ]; then
    echo "Generated fake log data in '$LOG_FILE'."
else
    echo "Error: failed to generate log data." >&2
    exit 1
fi

# --- Step 2: run analysis, sending summary to results.txt, errors to errors.log ---
{
    echo "===== Log Analysis Summary ====="
    echo ""

    echo "--- Total lines ---"
    wc -l < "$LOG_FILE"
    echo ""

    echo "--- Count per log level ---"
    awk '{print $3}' "$LOG_FILE" | sort | uniq -c | sort -rn
    echo ""

    echo "--- Top 3 IPs ---"
    awk '{print $4}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -n 3
    echo ""

    echo "--- All ERROR lines ---"
    grep "ERROR" "$LOG_FILE"
} > "$RESULTS_FILE" 2> "$ERRORS_FILE"

if [ $? -eq 0 ]; then
    echo "Analysis complete. Summary written to '$RESULTS_FILE'."
else
    echo "Error: analysis pipeline failed - check '$ERRORS_FILE'." >&2
    exit 1
fi

if [ -s "$ERRORS_FILE" ]; then
    echo "Note: some pipeline errors were captured in '$ERRORS_FILE'."
else
    echo "No pipeline errors encountered."
fi

exit 0
