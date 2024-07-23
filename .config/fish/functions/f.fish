function f --wraps='find . | grep ' --description 'alias f=find . | grep '
  find . | grep  $argv
        
end
