#!/bin/bash

hostname="$(hostname -f)"

if [ $# -lt 1 ]; then 
	echo "[ERROR] Insufficient # of params"
	echo "USAGE: `dirname $0`/$0 <scaleFactor> [maxWidth]"
	exit 127
fi

source  ../../PerfTestEnv.conf

scale=$1

#set up workspace
cur_dir=`pwd`
cd $TestKitDir/utils
cat dfs.json_Template|sed "s/scaleFactor/${scale}/g" > dfs.json
./set_storage_plugin.sh

cd $cur_dir

schema=tpchParquet

maxWidthToUse=2
if [ $# -gt 1 ]; then 
    maxWidthToUse=$2
fi

#Check Dir on HDFS
schemaExists=`hadoop fs -du -s /${schema}/SF${scale} | awk '{print $1}'`
if [ $schemaExists ]; then
	if [ $schemaExists -gt 0 ]; then 
		echo "[ERROR]: Location has data ($schemaExists bytes): /${schema}/SF${scale}"
		exit 127
	fi
fi
###

#Creating schema Directory (if not existent)
echo "Creating schema Directory (if not existent)"
hadoop fs -mkdir -p /${schema}/SF${scale}


STARTTIME=`date +%s`
echo "Start time of the Drill Query "`date +%H:%M:%S`

for tbl in `cat tpch_tables`; do
    echo "Writing table - $tbl"

#SKIP::alter session set \`planner.width.max_per_node\`=${maxWidthToUse};
sqlline -u "jdbc:drill:schema=dfs.${schema}:drillbit=$hostname:31010;auth=MAPRSASL"  << EOF  &
use dfs.${schema};
create table ${tbl} as select * from dfs.\`/tpchView/SF$scale/${tbl}_csv$scale\`;
EOF
done

wait;

echo "Exit code $?"
ENDTIME=`date +%s`
     
echo "Query time is: `expr $ENDTIME - $STARTTIME` sec"

