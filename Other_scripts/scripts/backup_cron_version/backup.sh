#!/bin/bash

# Source directory to backup
source_dir="/home/ubuntu/test"

# Backup directory
backup_dir="/home/ubuntu/cron_backup"

# Number of versions to keep
num_versions=5

# Create backup directory if it doesn't exist
mkdir -p "$backup_dir"

# Create timestamp
timestamp=$(date +%Y-%m-%d_%H-%M-%S)

# Perform backup
rsync -a "$source_dir" "$backup_dir/backup_$timestamp"

# Rotate backups
backup_count=$(ls -1 "$backup_dir" | grep -c "backup_")
if [ $backup_count -gt $num_versions ]; then
    num_to_delete=$((backup_count - num_versions))
    ls -1tr "$backup_dir" | grep "backup_" | head -n $num_to_delete | xargs -I {} rm -rf "$backup_dir/{}"
fi

