# Mirror !! functionality
function last_history_item
    echo $history[1]
end
abbr --position anywhere -a "!!" --function last_history_item
