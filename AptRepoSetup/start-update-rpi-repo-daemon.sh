#!/bin/sh
# https://unix.stackexchange.com/questions/24952/script-to-monitor-folder-for-new-files
inotifywait -m /www/wwwroot/rpi.kxxt.tech --exclude Packages.gz -e moved_to -e delete -e close_write |
    while read dir action file; do
        echo "'$action' on '$file' in '$dir' triggered updation of Packages.gz"
        update-rpi-repo.sh
    done