function whatsmyip
    echo -n "Local IP Address -> " 
    hostname -i | awk '{print $3}'
    echo -n "Public IP Address -> "
    curl https://ipinfo.io/ip
    echo
end
