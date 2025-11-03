#!/bin/bash

DIRS_GETTER="./get_source_and_target_dirs.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_info() {
    local message=$1
    echo -e "${GREEN}[INFO]${NC} in $0: $message"
}

print_warning() {
    local message=$1
    echo -e "${YELLOW}[WARNING]${NC} in $0: $1"
}

print_error() {
    local message=$1
    echo -e "${RED}[ERROR]${NC} in $0: $1" >&2
}

if [ ! -f "$DIRS_GETTER" ]; then
    print_error "Script $DIRS_GETTER not found"
    exit 1
fi

if ! source_target_dirs=$("$DIRS_GETTER"); then
    print_error "Failed to get directories"
    exit 1
fi

SOURCE_DIR=$(echo "$source_target_dirs" | awk -F'|' '{print $1}')
TARGET_DIR=$(echo "$source_target_dirs" | awk -F'|' '{print $2}')

if [ -z "$SOURCE_DIR" ] || [ -z "$TARGET_DIR" ]; then
    print_error "Could not parse source and target directories"
    exit 1
fi

DELETE=""
# DELETE="--delete"  # Uncomment to switch delete
EXCLUDE="--exclude='*.tmp' --exclude='.DS_Store'"

# Dry run - show what would be synchronized
dry_run() {
    print_info "DRY RUN - showing what would be synchronized:"
    print_info "From: $SOURCE_DIR"
    print_info "To: $TARGET_DIR"
    
    rsync -avun "$DELETE" "$EXCLUDE" "$SOURCE_DIR" "$TARGET_DIR"
}

# Actual synchronization
sync_dirs() {
    print_info "Starting synchronization..."
    print_info "From: $SOURCE_DIR"
    print_info "To: $TARGET_DIR"
    
    # Base rsync command
    local rsync_cmd="rsync -av --progress"
    
    # Add common extras
    rsync_cmd="$rsync_cmd $DELETE"
    rsync_cmd="$rsync_cmd $EXCLUDE"
    
    # Execute rsync
    $rsync_cmd "$SOURCE_DIR" "$TARGET_DIR"

    if [ $? -eq 0 ]; then
        print_info "Synchronization completed successfully!"
    else
        print_error "Synchronization failed!"
        return 1
    fi
}

ask_sync_run() {
    read -p "Run synchronization? (Y/N): " answer
    case "${answer}" in
        [Yy]* ) return 0;;
        * ) return 1;;
    esac
}


# main
dry_run

if ask_sync_run; then
    sync_dirs
else
    print_warning "Cancel synchronization"
fi