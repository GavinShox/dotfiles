function diskspace --wraps='du -S -h | sort -h -r |more' --description 'alias diskspace=du -S -h | sort -h -r |more'
  du -S -h | sort -h -r |more $argv
        
end
