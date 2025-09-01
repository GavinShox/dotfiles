function rmv --wraps='/bin/rm' --description 'alias rmv=rm: lets you use the actual rm command instead of the trash-cli alias'
  /bin/rm -i $argv

end
