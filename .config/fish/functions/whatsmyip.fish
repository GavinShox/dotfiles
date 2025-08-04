function whatsmyip
    echo -n "Local IP Address -> " 
    hostname -I | awk '{print $1}'
    echo -n "Public IP Address -> "
    curl https://ipinfo.io/ip
    echo
end
