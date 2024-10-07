pgrep skynet | while read -r pid; do  
    kill -9 "$pid"  
    echo "kill skynet, pid:$pid"
done
