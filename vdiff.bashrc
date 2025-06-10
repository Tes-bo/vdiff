vdiff() {
    # Compare only different files between two directories
    # Usage: vdiff dir1 dir2
    
    # Check arguments
    if [ $# -ne 2 ]; then
        echo "Usage: vdiff <directory1> <directory2>"
        return 1
    fi
    
    # Check if directories exist
    for dir in "$1" "$2"; do
        [ ! -d "$dir" ] && echo "Error: Directory '$dir' does not exist" && return 1
    done
    
    # Get absolute paths
    DIR1=$(realpath "$1")
    DIR2=$(realpath "$2")
    
    # Create temporary files
    DIFF_FILES=$(mktemp /tmp/vdiff_files.XXXXXX)
    STATUS_FILE=$(mktemp /tmp/vdiff_status.XXXXXX)
    
    # Generate list of different files
    echo "Finding different files..."
    diff -rq "$DIR1" "$DIR2" | grep -E 'differ|Only in' > "$DIFF_FILES"
    
    # Process diff output to extract file paths
    awk -v dir1="$DIR1" -v dir2="$DIR2" '
    /differ/ {
        sub(dir1 "/", "", $2);
        sub(dir2 "/", "", $4);
        print ($2 == $4) ? $2 : $2 " <=> " $4
    }
    /Only in/ {
        split($0, a, ": ");
        split(a[1], b, " ");
        dir = b[3]; sub(dir1, "", dir); sub(dir2, "", dir);
        file = a[2];
        print (dir ~ dir1) ? dir "/" file : dir "/" file
    }
    ' "$DIFF_FILES" > "${DIFF_FILES}.processed"
    
    mv "${DIFF_FILES}.processed" "$DIFF_FILES"
    
    # Count different files
    FILE_COUNT=$(wc -l < "$DIFF_FILES")
    
    if [ "$FILE_COUNT" -eq 0 ]; then
        echo "No differences found"
        rm -f "$DIFF_FILES" "$STATUS_FILE"
        return 0
    fi
    
    echo "Found $FILE_COUNT different files"
    
    # Process different files
    CURRENT=1
    TOTAL=$FILE_COUNT
    
    while [ "$CURRENT" -le "$TOTAL" ]; do
        REL_PATH=$(sed -n "${CURRENT}p" "$DIFF_FILES")
        FILE1="${DIR1}/${REL_PATH}"
        FILE2="${DIR2}/${REL_PATH}"
        
        # Handle missing files
        MISSING1=0; MISSING2=0
        [ ! -f "$FILE1" ] && FILE1=$(mktemp /tmp/vdiff_missing1.XXXXXX) && touch "$FILE1" && MISSING1=1
        [ ! -f "$FILE2" ] && FILE2=$(mktemp /tmp/vdiff_missing2.XXXXXX) && touch "$FILE2" && MISSING2=1
        
        # Create Vim script
        VIM_SCRIPT=$(mktemp /tmp/vdiff_vim.XXXXXX)
        cat > "$VIM_SCRIPT" <<EOF
set title
set titlestring=$REL_PATH
if argc() == 2
  wincmd l
  set buftype=nofile
  set bufhidden=delete
  set noswapfile
  wincmd h
  set buftype=nofile
  set bufhidden=delete
  set noswapfile
endif

command! ExitDiff let g:vdiff_next = -1 | !echo -1 > $STATUS_FILE | qa!
nnoremap <silent> <leader>q :ExitDiff<CR>
EOF
        
        # Open files
        echo "$CURRENT" > "$STATUS_FILE"
        vim -d -S "$VIM_SCRIPT" "$FILE1" "$FILE2"
        
        # Cleanup
        [ "$MISSING1" -eq 1 ] && rm -f "$FILE1"
        [ "$MISSING2" -eq 1 ] && rm -f "$FILE2"
        rm -f "$VIM_SCRIPT"
        
        # Check exit status
        LAST_STATUS=$(cat "$STATUS_FILE")
        [ "$LAST_STATUS" -eq -1 ] && break
        
        CURRENT=$((CURRENT + 1))
    done
    
    # Final cleanup
    rm -f "$DIFF_FILES" "$STATUS_FILE"
    echo "Comparison completed"
}
