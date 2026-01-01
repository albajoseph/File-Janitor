#!/usr/bin/env bash
echo "File Janitor, $(date +'%Y')"
echo "Powered by Bash"
echo ""

if [ "$1" = "help" ]; then
    cat file-janitor-help.txt
elif [ "$1" = "list" ]; then
    DIR_PATH=$2
    if [ -z "$DIR_PATH" ]; then
        echo "Listing files in the current directory"
        ls -A1 | sort
    elif [ ! -e "$DIR_PATH" ]; then
        echo "$DIR_PATH is not found"
    elif [ ! -d "$DIR_PATH" ]; then
        echo "$DIR_PATH is not a directory"
    else
        echo "Listing files in $DIR_PATH"
        ls -A1 "$DIR_PATH" | sort
    fi
elif [ "$1" = "report" ]; then
    DIR_PATH=$2
    if [ -z "$DIR_PATH" ]; then
        echo "The current directory contains:"
        DIR_PATH="."
    elif [ ! -e "$DIR_PATH" ]; then
        echo "$DIR_PATH is not found"
        exit 1
    elif [ ! -d "$DIR_PATH" ]; then
        echo "$DIR_PATH is not a directory"
        exit 1
    else 
        echo "$DIR_PATH contains:"
    fi
    tmp_count=$(find "$DIR_PATH" -maxdepth 1 -type f -name "*.tmp" | wc -l | tr -d ' ')
    tmp_size=$(find "$DIR_PATH" -maxdepth 1 -type f -name "*.tmp" -exec wc -c {} + | tail -n 1 | rev | cut -d' ' -f2 | rev)
    [ -z "$tmp_size" ] && tmp_size=0
    echo "$tmp_count tmp file(s), with total size of $tmp_size bytes"
    log_count=$(find "$DIR_PATH" -maxdepth 1 -type f -name "*.log" | wc -l | tr -d ' ')
    log_size=$(find "$DIR_PATH" -maxdepth 1 -type f -name "*.log" -exec wc -c {} + | tail -n 1 | rev | cut -d' ' -f2 | rev)
    [ -z "$log_size" ] && log_size=0
    echo "$log_count log file(s), with total size of $log_size bytes"
    py_count=$(find "$DIR_PATH" -maxdepth 1 -type f -name "*.py" | wc -l | tr -d ' ')
    py_size=$(find "$DIR_PATH" -maxdepth 1 -type f -name "*.py" -exec wc -c {} + | tail -n 1 | rev | cut -d' ' -f2 | rev)
    [ -z "$py_size" ] && py_size=0
    echo "$py_count py file(s), with total size of $py_size bytes"
elif [ "$1" = "clean" ]; then
    DIR_PATH=$2
    if [ -z "$DIR_PATH" ]; then
        echo "Cleaning the current directory..."
        DIR_PATH="."
        CLEAN_MSG="the current directory"
    elif [ ! -e "$DIR_PATH" ]; then
        echo "$DIR_PATH is not found"
        exit 1
    elif [ ! -d "$DIR_PATH" ]; then
        echo "$DIR_PATH is not a directory"
        exit 1
    else
        echo "Cleaning $DIR_PATH..."
        CLEAN_MSG="$DIR_PATH"
    fi
    
    # 1. Log files
    echo -n "Deleting old log files... "
    n_logs=$(find "$DIR_PATH" -maxdepth 1 -type f -name "*.log" -mtime +3 | wc -l | tr -d ' ')
    find "$DIR_PATH" -maxdepth 1 -type f -name "*.log" -mtime +3 -delete
    echo " done! $n_logs files have been deleted"
    
    # 2. Temporary files
    echo -n "Deleting temporary files... "
    n_tmp=$(find "$DIR_PATH" -maxdepth 1 -type f -name "*.tmp" | wc -l | tr -d ' ')
    find "$DIR_PATH" -maxdepth 1 -type f -name "*.tmp" -delete
    echo " done! $n_tmp files have been deleted"
    
    # 3. Python files
    echo -n "Moving python files... "
    n_py=$(find "$DIR_PATH" -maxdepth 1 -type f -name "*.py" | wc -l | tr -d ' ')
    if [ "$n_py" -gt 0 ]; then
        mkdir -p "$DIR_PATH/python_scripts"
        find "$DIR_PATH" -maxdepth 1 -type f -name "*.py" -exec mv {} "$DIR_PATH/python_scripts/" \;
    fi
    echo " done! $n_py files have been moved"
    
    echo ""
    echo "Clean up of $CLEAN_MSG is complete!"
else
    echo "Type $0 help to see available options"
fi
