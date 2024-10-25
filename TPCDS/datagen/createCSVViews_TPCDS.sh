#!/bin/bash

hostname="$(hostname -f)"

if [ $# -lt 1 ]; then
        echo "[ERROR] Insufficient # of params"
        echo "USAGE: `dirname $0`/$0  <scaleFactor>"
        exit 127
fi

##those are the default MapR Drill installation dirs and files, make sure the DRILL_HOME is set correctly
source  ../../PerfTestEnv.conf

scaleFactor=$1

#set up workspace
cur_dir=`pwd`
cd $TestKitDir/utils
cat dfs.json_Template|sed "s/scaleFactor/${scaleFactor}/g" > dfs.json
./set_storage_plugin.sh

cd $cur_dir

viewPath=tpcdsView

#Check Dir on HDFS
viewExists=`hadoop fs -du -s /${viewPath}/SF${scaleFactor} | awk '{print $1}'`
if [ $viewExists ]; then
        if [ $viewExists -gt 0 ]; then
                echo "[ERROR]: Location has data ($viewExists bytes): /${viewPath}/SF${scaleFactor}"
                exit 127
        fi
fi
###

#Creating View Directory (if not existent)
echo "Creating View Directory (if not existent)"
hadoop fs -mkdir -p /${viewPath}/SF${scaleFactor}

cp -f createCSVViews_TPCDS_Template.sql createTPCDS_CSVViews-SF$scaleFactor.sql
sed -i "s|ScaleFactor|$scaleFactor|g" createTPCDS_CSVViews-SF$scaleFactor.sql

sqlline -u "jdbc:drill:schema=dfs.${viewPath}:drillbit=$hostname:31010;auth=MAPRSASL" -f createTPCDS_CSVViews-SF$scaleFactor.sql
