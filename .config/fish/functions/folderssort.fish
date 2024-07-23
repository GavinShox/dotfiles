function folderssort --wraps='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn' --description 'alias folderssort=find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
  find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn $argv
        
end
