#!/bin/bash

source  ../../PerfTestEnv.conf

hostname=$(cat "$TestKitDir"/drillbits.lst)

if [ $# -lt 1 ]; then 
	echo "[ERROR] Insufficient # of params"
	echo "USAGE: `dirname $0`/$0  <scaleFactor>"
	exit 127
fi

##those are the default MapR Drill installation dirs and files, make sure the DRILL_HOME is set correctly

scaleFactor=$1
viewPath=tpchView

#set up workspace
cur_dir=`pwd`
cd $TestKitDir/utils
cat dfs.json_Template|sed "s|scaleFactor|${scaleFactor}|g" > dfs.json
./set_storage_plugin.sh

cd $cur_dir

# Check Dir on HDFS and clean if exists
viewExists=`hadoop fs -du -s /${viewPath}/SF${scaleFactor} | awk '{print $1}'`
if [ $viewExists -gt 0 ]; then
  echo "[INFO]: Directory exists AT /${viewPath}/SF${scaleFactor}"
  #echo "[INFO]: Removing existing view at /${viewPath}/SF${scaleFactor}"
  #hadoop fs -rm -r -skipTrash /${viewPath}/SF${scaleFactor}
fi
###

#Creating View Directory (if not existent)
echo "Creating View Directory (if not existent)"
hadoop fs -mkdir -p /${viewPath}/SF${scaleFactor}

cp -f createCSVViews_TPCH_Template.sql createCSVViews-SF$scaleFactor.sql
sed -i "s|ScaleFactor|$scaleFactor|g" createCSVViews-SF$scaleFactor.sql

sqlline -u "jdbc:drill:schema=dfs.${viewPath}:drillbit=$hostname:31010;auth=MAPRSASL" -f createCSVViews-SF$scaleFactor.sql
