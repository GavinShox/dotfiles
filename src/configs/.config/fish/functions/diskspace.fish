function diskspace --wraps='du -d1 -h | sort -h' --description 'alias diskspace=du -d1 -h | sort -h'
  du -d1 -h --all $argv | sort -h
        
end
