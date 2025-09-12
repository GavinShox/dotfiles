function p --wraps='ps aux | grep ' --description 'alias p=ps aux | grep '
  ps aux | grep  $argv
        
end
