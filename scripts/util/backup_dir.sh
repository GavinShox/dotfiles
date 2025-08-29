#!/bin/bash

if [[ -d $1 ]]; then
	i=1
	while [[ -d $1.bak$i ]]; do
		let i++
	done

	backup_dir=$1.bak$i
	cp -r $1 $backup_dir
	echo "Backup of directory ${1} made at ${backup_dir}"
fi
