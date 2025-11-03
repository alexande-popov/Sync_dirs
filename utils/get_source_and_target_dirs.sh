#!/bin/bash

# Check source & target dirs and return their pathes
# Output:  "source_dir_path|target_dir_path"

INPUT_SOURCE="../data/source_dir.txt"
INPUT_TARGET="../data/target_dir.txt"

print_error() {
    local message=$1
    echo "Error in $0: $message" >&2
}

check_input() {
    local input_file=$1
    if [ ! -f "$input_file" ]; then
        print_error "File $input_file not exist"
        return 1
    elif [ ! -s "$input_file" ]; then
        print_error "File $input_file is empty"
        return 1
    fi
    return 0
}

if ! check_input "$INPUT_SOURCE" || ! check_input "$INPUT_TARGET"; then
    exit 1
fi

SOURCE=$(cat "$INPUT_SOURCE")
TARGET=$(cat "$INPUT_TARGET")

[[ "$SOURCE" != */ ]] && SOURCE="$SOURCE/"
[[ "$TARGET" != */ ]] && TARGET="$TARGET/"

for dir in "$SOURCE" "$TARGET"; do
    if [ ! -e "$dir" ] || [ ! -d "$dir" ]; then
        print_error "Bad dir $dir"
        exit 1
    fi
done

echo "${SOURCE}|${TARGET}"