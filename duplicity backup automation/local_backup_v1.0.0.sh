#! /bin/bash

<< 'MULTILINE-COMMENT'

Script to automate the duplicity backups and upload to sftp.
version : v1.0.0
dependencies: ssh , duplicity

Input parms:

    # n = backup name (will be the folder on remote where the backup in created)
    eg: test backup

    # s = fq path of the folder to backup
    eg: /home/bkadmin/test

    # d = destination where backup will be created (sftp server should be accessible via ssh)
    eg: sftp://root@192.123.122.1///media/backups

    # k= the gpg public key to perform the encryption (public key needs to be imported to local device.)
    eg: D939E4E4330E82D9B943B01BB1F2F00F6CABB775
    
    # e = foldes / files to exclude
    eg: **node_modules/**,**.git/**

MULTILINE-COMMENT

# each backup will generate the logs on below location
log_path=$(eval echo ~$USER)"/backup.local"
date=$(date "+%Y-%m-%d_%H.%M.%S")
log="$log_path/backup_logs/$date.log"

process_input () {

    if [ -d "$source" ] 
    then
        echo "[info] source directory exists : $source" 
    else
        echo "[error] source directory $source does not exists."
        exit
    fi

    # create log folder and check folder exists
    echo "[info] creating the log folder: $log_path$/backup_logs"
    mkdir -p "$log_path/backup_logs"

    if [ -d "$log_path" ] 
    then
        echo "[info] log_path directory exists : $log_path" 
    else
        echo "[error] log_path directory $log_path does not exists."
        exit
    fi

    # check gpg key exists locally 

    if [[ $(gpg --list-keys | grep -w $encrypt_key_id) ]]
    then
        echo "[info] encryption key exists : $encrypt_key_id" 
    else
        echo "[error] encryption key does not exists : $encrypt_key_id" 
        exit
    fi

    # construct the sftp name
    sftp_destination+="${backup_name// /_}"
    # extract the backup server IP
    backup_server_ip="$(grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' <<< "$sftp_destination")"

    # set the SSH_AUTH_SOCK variable : https://askubuntu.com/questions/1277786/duplicity-ssh-error-only-when-run-by-cron
    export SSH_AUTH_SOCK='/run/user/1000/keyring/ssh'
    ssh_auth_from_env=$(env | grep SSH_AUTH)

}

add_exclude_list () {
    # exclude dir list
    echo "[info] below foldes/files will be ignored during the backup process:"
    for i in ${exclude_folders//,/ }
    do
        echo -e "\t $i"
        exclude_command+="--exclude '${i}' "
    done
}

start_backup(){
    # start backup process
    log_path="file://"$log_path
    echo "[info] starting the backup process at $date : "
    cmd="duplicity --allow-source-mismatch "$exclude_command" --encrypt-key "$encrypt_key_id" $source"" "$sftp_destination""" --asynchronous-upload --max-blocksize=2097152 --verbosity notice --log-file $log" 
    #echo "$cmd"> $log
    #echo "-----------"
    eval $cmd

    echo -e "\nNOTICE 2\n. --------------[ Commadn Info ]--------------\n. Command executed: $cmd \n. Backup Name: $backup_name \n. Source Folder: $source \n. Destination: $sftp_destination \n. SSH_AUTH_SOCK: $ssh_auth_from_env \n. Encrypt-key: $encrypt_key_id \n------------------------------------------------- " >> $log
    echo -e "[info] backup process completed at : "$(date "+%Y-%m-%d_%H.%M.%S") 
    notify-send "Local Backup" "$backup_name - backup completed" -t 100
    echo -e "[info] backup log file : $log"
}

# extract input params
# n = name of the backup
# s = source folder
# d = destination
# k = encrypt key id
# e = exclude folder list
while getopts n:s:d:k:e: flag
do
    case "${flag}" in
        n) backup_name=${OPTARG};;
        s) source=${OPTARG};;
        d) sftp_destination=${OPTARG};;
        k) encrypt_key_id=${OPTARG};;
        e) exclude_folders=${OPTARG};;                
    esac
done

process_input
add_exclude_list

# check the network server is accessible
if nc -z $backup_server_ip 22 2>/dev/null; then
    echo "backup server $backup_server_ip online ✓"
    start_backup
else
    echo "backup server $backup_server_ip offline ✗" > $log
fi


