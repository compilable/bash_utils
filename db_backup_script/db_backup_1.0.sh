#!/bin/bash

# 
# This file is part of the Bash-Tools distribution (https://github.com/compilable/Bash-Tools).
# Copyright (c) 2023 compilable.
# 
# This program is free software: you can redistribute it and/or modify  
# it under the terms of the GNU General Public License as published by  
# the Free Software Foundation, version 3.
#
# This program is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License 
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

# Introduction: This script can be configured to run as a deamon service to periodically backup the full database and upload to git repo.

# version : 1.0.0
# dependencies : zip (http://www.info-zip.org/) , git


# 1. location to keep the backup data. 
backup_folder=../test_data/db_backups
mkdir -p $backup_folder

# 2. mysql settings
db_user=<REPLACE>
db_password=<REPLACE>

# 3. number of days to keep the local backup files. 
keep_day=30 

# 4. zip file settings
sqlfile=$backup_folder/test_db_$(date +%d-%m-%Y_%H-%M-%S).sql
zipfile=$backup_folder/test_db_$(date +%d-%m-%Y_%H-%M-%S).zip
zipfile_password=<REPLACE>

# 5. use the db specific command to create a db backup. 
sudo mysqldump -u $db_user -p$db_password test_db > $sqlfile

if [ $? == 0 ]; then
  echo "INFO : db dump file created : $sqlfile"
else
  echo "ERROR : db dump file creating failed : $sqlfile"
  exit 
fi 

# 6. compress and encrypt the geneated file.
zip --password $zipfile_password $zipfile $sqlfile 
if [ $? == 0 ]; then
    rm $sqlfile 
    echo 'INFO : The backup was successfully compressed and removed.' 
else
  echo "ERROR : The backup was not compressed."
  exit 
fi

# 7. removing the old backup files:
find $backup_folder -mtime +$keep_day -delete

# 8. push the changes to git.
git add $zipfile
git commit -m 'backup file added for '$(date +%d-%m-%Y_%H-%M-%S)
git push
echo 'INFO : The new backup is commited and pushed to the git.' 