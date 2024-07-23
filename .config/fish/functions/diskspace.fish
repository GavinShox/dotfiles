function diskspace --wraps='du -S | sort -n -r |more' --description 'alias diskspace=du -S | sort -n -r |more'
  du -S | sort -n -r |more $argv
        
end
