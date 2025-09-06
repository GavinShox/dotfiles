function diskspace --wraps='du -d1 -h | sort -h -r' --description 'alias diskspace=du -d1 -h | sort -h -r'
  du -d1 -h | sort -h -r
        
end
