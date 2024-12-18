#!/bin/bash

set -x

drillbit=`head -1 ../drillbits.lst`
tmstmp=`date +%Y%m%d_%H%M%S`

curl -X POST \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -k -c cookies.txt -s \
      -d "j_username=mapr" \
      -d "j_password=mapr" \
      https://${drillbit}:8047/j_security_check

curl -kv \
       -X GET \
       -b cookies.txt  \
       -H "Content-Type: application/json" \
        https://${drillbit}:8047/storage/dfs.json > dfs.json.SAVED.$tmstmp

curl -kv \
       -b cookies.txt  \
       -X POST \
       -H "Content-Type: application/json" \
       -d @dfs.json https://${drillbit}:8047/storage/dfs.json
