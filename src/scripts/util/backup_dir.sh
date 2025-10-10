#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

if [[ -d $1 ]]; then
	i=1
	while [[ -d $1.bak$i ]]; do
		let i++
	done

	backup_dir=$1.bak$i
	cp -r $1 $backup_dir
	echo -e "${CYAN}Backup of directory ${1} made at ${backup_dir}${NC}"
else
	echo -e "${YELLOW}Directory ($1) doesn't exist, nothing to backup${NC}"
fi
