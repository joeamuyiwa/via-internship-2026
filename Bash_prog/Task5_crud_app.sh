#!/usr/bin/env bash
# ---------------------------------------------------
# @title       Task5_crud_app.sh
# @author      Jospeh Ayofolaji Joseph 
# @index       5230160112
# @school      University of Skilled Training and Entrepreneurial Development (USTED)
# @description CRUD Todo List app storing data in a CSV file,
#              with backups before changes.
# @date        14-09-2026
# ---------------------------------------------------

DATA_FILE="todo_data.csv"
BACKUP_FILE="todo_data.csv.bak"

usage() {
    echo "Usage: $0"
    echo "  Launches an interactive menu-driven Todo List manager."
    exit 1
}

if [ $# -ne 0 ]; then
    usage
fi

# Ensure data file exists so reads never fail on a missing file.
if [ ! -f "$DATA_FILE" ]; then
    touch "$DATA_FILE"
fi

backup_data() {
    cp "$DATA_FILE" "$BACKUP_FILE"
    if [ $? -ne 0 ]; then
        echo "Warning: failed to create backup before destructive change." >&2
    fi
}

create_task() {
    read -p "Enter task description: " DESC
    if [ -z "$DESC" ]; then
        echo "Error: task description cannot be empty." >&2
        return 1
    fi
    NEXT_ID=$(( $(wc -l < "$DATA_FILE") + 1 ))
    echo "$NEXT_ID,$DESC,pending" >> "$DATA_FILE"
    if [ $? -eq 0 ]; then
        echo "Task added with ID $NEXT_ID."
    else
        echo "Error: failed to add task." >&2
        return 1
    fi
}

read_tasks() {
    if [ ! -s "$DATA_FILE" ]; then
        echo "No tasks found."
        return 0
    fi
    echo "----- Task List -----"
    printf "%-5s %-40s %-10s\n" "ID" "Description" "Status"
    while IFS=',' read -r ID DESC STATUS; do
        printf "%-5s %-40s %-10s\n" "$ID" "$DESC" "$STATUS"
    done < "$DATA_FILE"
    echo "----------------------"
}

update_task() {
    read -p "Enter ID of task to update: " ID
    if ! grep -q "^$ID," "$DATA_FILE"; then
        echo "Error: task with ID $ID not found." >&2
        return 1
    fi
    read -p "Enter new description (leave blank to keep current): " NEW_DESC
    read -p "Enter new status (pending/done, leave blank to keep current): " NEW_STATUS

    backup_data

    TMP_FILE=$(mktemp)
    while IFS=',' read -r LINE_ID LINE_DESC LINE_STATUS; do
        if [ "$LINE_ID" = "$ID" ]; then
            [ -n "$NEW_DESC" ] && LINE_DESC="$NEW_DESC"
            [ -n "$NEW_STATUS" ] && LINE_STATUS="$NEW_STATUS"
        fi
        echo "$LINE_ID,$LINE_DESC,$LINE_STATUS" >> "$TMP_FILE"
    done < "$DATA_FILE"

    mv "$TMP_FILE" "$DATA_FILE"
    if [ $? -eq 0 ]; then
        echo "Task $ID updated."
    else
        echo "Error: failed to update task $ID." >&2
        return 1
    fi
}

delete_task() {
    read -p "Enter ID of task to delete: " ID
    if ! grep -q "^$ID," "$DATA_FILE"; then
        echo "Error: task with ID $ID not found." >&2
        return 1
    fi
    read -p "Are you sure you want to delete task $ID? (y/n): " CONFIRM
    if [ "$CONFIRM" != "y" ]; then
        echo "Deletion cancelled."
        return 0
    fi

    backup_data

    TMP_FILE=$(mktemp)
    grep -v "^$ID," "$DATA_FILE" > "$TMP_FILE"
    mv "$TMP_FILE" "$DATA_FILE"
    if [ $? -eq 0 ]; then
        echo "Task $ID deleted. Backup saved at '$BACKUP_FILE'."
    else
        echo "Error: failed to delete task $ID." >&2
        return 1
    fi
}

show_menu() {
    echo ""
    echo "===== Todo List Manager ====="
    echo "1) Add task"
    echo "2) View tasks"
    echo "3) Update task"
    echo "4) Delete task"
    echo "5) Exit"
    echo "=============================="
}

while true; do
    show_menu
    read -p "Choose an option [1-5]: " CHOICE
    case "$CHOICE" in
        1) create_task ;;
        2) read_tasks ;;
        3) update_task ;;
        4) delete_task ;;
        5) echo "Goodbye."; exit 0 ;;
        *) echo "Invalid option, please choose 1-5." ;;
    esac
done
