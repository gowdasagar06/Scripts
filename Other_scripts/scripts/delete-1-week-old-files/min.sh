#!/bin/bash

# Function to delete files modified within the last 5 minutes and create an archive
delete_recent_files_and_archive() {
    # Set the threshold date for deletion (5 minutes ago)
    threshold_date=$(date -d '30 minutes ago' +%Y-%m-%d\ %H:%M:%S)
    
    # Create a timestamp for the archive filename
    timestamp=$(date +%Y-%m-%d_%H-%M-%S)
    
    # Create a temporary directory for files to archive
    temp_dir=$(mktemp -d)
    
    # Find files modified within the last 5 minutes and move them to the temporary directory
    find "$1" -type f -newermt "$threshold_date" -exec mv {} "$temp_dir" \;
    
    # Create a compressed archive of the files
    if [ "$(ls -A "$temp_dir")" ]; then
        archive_name="archive_$timestamp.zip"
        zip -r "$archive_name" "$temp_dir"/*
        echo "Files modified within the last 5 minutes have been moved and archived as '$archive_name'"
    else
        echo "No files modified within the last 5 minutes found to move."
    fi
    
    # Clean up temporary directory
    rm -rf "$temp_dir"
}

# Example usage
directory_to_clean="/home/ubuntu/test"
delete_recent_files_and_archive "$directory_to_clean"

