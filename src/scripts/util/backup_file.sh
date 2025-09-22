#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

if [ ! -e $1 ]; then
	echo -e "${YELLOW}$1 doesn't exist, nothing to backup.${NC}"
	exit 1
fi

if [[ -e $1.bak ]]; then
	i=1
	while [[ -e $1.bak$i ]]; do
		let i++
	done
	backup_file=$1.bak$i
else
	backup_file=$1.bak
fi

cp $1 $backup_file
echo -e "${GREEN}Backup of file ${1} made at ${backup_file}${NC}"
