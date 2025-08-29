#!/bin/bash

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
echo "Backup of file ${1} made at ${backup_file}"
