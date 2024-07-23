function openports --wraps='netstat -nape --inet' --description 'alias openports=netstat -nape --inet'
  netstat -nape --inet $argv
        
end
