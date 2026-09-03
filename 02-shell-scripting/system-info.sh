#!/bin/bash

# Store system information in variables
current_date=$(date)
current_hostname=$(hostname)
current_username=$(whoami)

echo "===== SYSTEM INFORMATION REPORT ====="
echo "Date: $current_date"
echo "Hostname: $current_hostname"
echo "Username: $current_username"

# Take directory name from the user
read -p "Enter report directory name [system-report]: " report_dir
report_dir=${report_dir:-system-report}

# Create the directory and process file
mkdir -p "$report_dir"

process_file="$report_dir/running-processes.txt"
touch "$process_file"

echo
echo "===== DISK USAGE ====="
df -h /

# Store all processes using output redirection
ps aux > "$process_file"

echo
echo "===== RUNNING PROCESSES - FIRST 10 ====="
head -n 10 "$process_file"

echo
echo "Processes saved to: $process_file"
ls -lh "$process_file"

echo
echo "===== REPORT COMPLETE ====="
