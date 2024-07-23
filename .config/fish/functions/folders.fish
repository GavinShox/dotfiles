function folders --wraps='du -h --max-depth=1' --description 'alias folders=du -h --max-depth=1'
  du -h --max-depth=1 $argv
        
end
