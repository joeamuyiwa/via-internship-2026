#!/usr/bin/env bash
# ---------------------------------------------------
# @title       Task1_file_handling.sh
# @author      Joseph Ayofolaji Oluwamuyiwa
# @index       5230160112
# @school      University of Skilled Training and Entrepreneurial Development (USTED)
# @description Directory creation  and file, writes/appends/reads content,
#              backup and deletetion
# @date        14-09-2026
# ---------------------------------------------------

usage() {
    echo "Usage: $0 <target-directory>"
    echo "  <target-directory>  the directory this script will create/use"
    exit 1
}

if [ $# -ne 1 ] || [ -z "$1" ]; then
    usage
fi

TARGET_DIR="$1"
FILE_NAME="notes.txt"
FILE_PATH="$TARGET_DIR/$FILE_NAME"

if [ -d "$TARGET_DIR" ]; then
    echo "Directory '$TARGET_DIR' already existed."
else
    mkdir -p "$TARGET_DIR"
    if [ $? -eq 0 ]; then
        echo "Directory '$TARGET_DIR' created successfully."
    else
        echo "Error: failed to create directory '$TARGET_DIR'." >&2
        exit 1
    fi
fi

echo "This is the first line of the file." > "$FILE_PATH"
if [ $? -eq 0 ]; then
    echo "File '$FILE_PATH' created and written to."
else
    echo "Error: failed to write to '$FILE_PATH'." >&2
    exit 1
fi

echo "This is an appended second line." >> "$FILE_PATH"
if [ $? -eq 0 ]; then
    echo "Content appended to '$FILE_PATH'."
else
    echo "Error: failed to append to '$FILE_PATH'." >&2
    exit 1
fi

if [ -r "$FILE_PATH" ]; then
    echo "----- Contents of $FILE_PATH -----"
    cat "$FILE_PATH"
    echo "-----------------------------------"
else
    echo "Error: cannot read '$FILE_PATH'." >&2
    exit 1
fi

cp "$FILE_PATH" "$FILE_PATH.bak"
if [ $? -eq 0 ]; then
    echo "Backup created: '$FILE_PATH.bak'."
else
    echo "Error: failed to create backup." >&2
    exit 1
fi

if [ -f "$FILE_PATH" ]; then
    read -p "Are you sure you want to delete '$FILE_PATH'? (y/n): " CONFIRM
    if [ "$CONFIRM" = "y" ]; then
        rm "$FILE_PATH"
        if [ $? -eq 0 ]; then
            echo "Original file '$FILE_PATH' deleted. Backup remains at '$FILE_PATH.bak'."
        else
            echo "Error: failed to delete '$FILE_PATH'." >&2
            exit 1
        fi
    else
        echo "Deletion cancelled by user."
    fi
else
    echo "Error: '$FILE_PATH' does not exist, nothing to delete." >&2
    exit 1
fi

exit 0
