#!/bin/bash


read -p "Enter the directory to check: " SOURCE_DIR

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

one_week_in_seconds=604800

current_time=$(date +%s)

files_list=$(ls -1 "$SOURCE_DIR")

files_to_archive=()

check_time(){
    for file in $files_list; do
        file_modification_time=$(stat -c "%Y" "$SOURCE_DIR/$file")
        time_difference=$((current_time - file_modification_time))
        if ((time_difference >= one_week_in_seconds)); then
            files_to_archive+=("$SOURCE_DIR/$file")
        fi
    done
}

create_archive(){
    tar -cvf "archive_${timestamp}.tar" "${files_to_archive[@]}"
}

delete_files(){
    rm -f "${files_to_archive[@]}"
}

check_time
create_archive
delete_files

