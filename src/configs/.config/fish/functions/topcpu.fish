function topcpu --wraps='/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10' --description 'alias topcpu=/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10'
  /bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10 $argv
        
end
