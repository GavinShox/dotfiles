function fsblk --wraps='lsblk -o NAME,RM,SIZE,FSAVAIL,FSUSE%,RO,TYPE,MOUNTPOINTS -e 7' --description 'alias fsblk=lsblk -o NAME,RM,SIZE,FSAVAIL,FSUSE%,RO,TYPE,MOUNTPOINTS -e 7'
  lsblk -o NAME,RM,SIZE,FSAVAIL,FSUSE%,RO,TYPE,FSTYPE,MOUNTPOINTS -e 7 $argv
        
end
