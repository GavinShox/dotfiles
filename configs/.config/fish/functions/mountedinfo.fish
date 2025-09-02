function mountedinfo --wraps='df -hT' --description 'alias mountedinfo=df -hT'
  df -hT $argv
        
end
