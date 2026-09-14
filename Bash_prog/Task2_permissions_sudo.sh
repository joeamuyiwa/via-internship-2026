#!/usr/bin/env bash
# ---------------------------------------------------
# @title       Task2_permissions_sudo.sh
# @author      Joseph Ayopfolaji Oluwamuyiwa
# @index       5230160112
# @school      University of Skilled Training and Entrepreneurial Development (USTED)
# @description Changing file permissions
#             .
# @date        14-09-2026
# ---------------------------------------------------

usage() {
    echo "Usage: $0 <file-path>"
    echo "  <file-path>  path to an existing file to inspect/modify"
    exit 1
}

if [ $# -ne 1 ] || [ -z "$1" ]; then
    usage
fi

FILE_PATH="$1"

if [ ! -e "$FILE_PATH" ]; then
    echo "Error: '$FILE_PATH' does not exist." >&2
    exit 1
fi

show_permissions() {
    local label="$1"
    echo "----- $label -----"
    ls -l "$FILE_PATH"
    local numeric
    numeric=$(stat -c "%a" "$FILE_PATH")
    echo "Numeric permissions: $numeric"
    echo "-------------------------------"
}

show_permissions "Permissions BEFORE changes"

chmod 644 "$FILE_PATH"
if [ $? -eq 0 ]; then
    echo "Applied numeric chmod 644 to '$FILE_PATH'."
else
    echo "Error: numeric chmod failed on '$FILE_PATH'." >&2
    exit 1
fi

chmod u+x "$FILE_PATH"
if [ $? -eq 0 ]; then
    echo "Applied symbolic chmod u+x to '$FILE_PATH'."
else
    echo "Error: symbolic chmod failed on '$FILE_PATH'." >&2
    exit 1
fi

CURRENT_UID=$(id -u)
if [ "$CURRENT_UID" -eq 0 ]; then
    echo "Running with root privileges - attempting chown on '$FILE_PATH'."
    chown root:root "$FILE_PATH"
    if [ $? -eq 0 ]; then
        echo "chown succeeded: '$FILE_PATH' is now owned by root:root."
    else
        echo "Error: chown failed on '$FILE_PATH' despite root privileges." >&2
    fi
else
    echo "Skipped chown step: root privileges are required and were not detected."
    echo "(Run this script with sudo if you want to test the chown step.)"
fi

show_permissions "Permissions AFTER changes"

exit 0
