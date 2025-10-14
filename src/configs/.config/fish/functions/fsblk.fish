function fsblk --wraps='lsblk -o NAME,RM,SIZE,FSAVAIL,FSUSE%,RO,TYPE,MOUNTPOINTS' --description 'alias fsblk=lsblk -o NAME,RM,SIZE,FSAVAIL,FSUSE%,RO,TYPE,MOUNTPOINTS'
  lsblk -o NAME,RM,SIZE,FSAVAIL,FSUSE%,RO,TYPE,MOUNTPOINTS $argv
        
end
