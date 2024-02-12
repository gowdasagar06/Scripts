#!/bin/bash

# Source directory to backup
source_dir="/home/ubuntu/test"

# Backup directory
backup_dir="/home/ubuntu/backup"

# Previous backup directory (for incremental updates)
previous_backup_dir="$backup_dir/previous_backup"

# Check if backup directories exist, create if not
mkdir -p "$backup_dir" "$previous_backup_dir" 2> /dev/null

# Check if previous backup exists
if [ ! -d "$previous_backup_dir" ]; then
    echo "No previous backup found. Creating initial backup."
    rsync -a --delete "$source_dir" "$backup_dir"
else
    echo "Performing incremental backup."
    rsync -a --delete --link-dest="$previous_backup_dir" "$source_dir" "$backup_dir/incremental_backup_$(date +%Y-%m-%d_%H-%M-%S)"
fi

# Compress the backup
if [ -d "$backup_dir/incremental_backup_$(date +%Y-%m-%d_%H-%M-%S)" ]; then
    tar -czf "$backup_dir/incremental_backup_$(date +%Y-%m-%d_%H-%M-%S).tar.gz" "$backup_dir/incremental_backup_$(date +%Y-%m-%d_%H-%M-%S)"
    
    # Remove uncompressed backup
    rm -rf "$backup_dir/incremental_backup_$(date +%Y-%m-%d_%H-%M-%S)"
#else
 #   echo "Failed to find the directory to compress."
fi

# Update the previous backup directory with the latest backup
rm -rf "$previous_backup_dir"
ln -s "$backup_dir/incremental_backup_$(date +%Y-%m-%d_%H-%M-%S)" "$previous_backup_dir"

