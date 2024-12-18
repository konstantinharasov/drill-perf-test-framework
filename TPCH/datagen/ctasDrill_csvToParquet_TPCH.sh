#!/bin/bash

source  ../../PerfTestEnv.conf

hostname=$(cat "$TestKitDir"/drillbits.lst)

if [ $# -lt 1 ]; then 
	echo "[ERROR] Insufficient # of params"
	echo "USAGE: `dirname $0`/$0 <scaleFactor> [maxWidth]"
	exit 127
fi

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

#Check Dir on HDFS and clean if exists
schemaExists=`hadoop fs -du -s /${schema}/SF${scale} | awk '{print $1}'`
if [ $schemaExists -gt 0 ]; then
  echo "[INFO]: Removing existing schema at /${schema}/SF${scale}"
  hadoop fs -rm -r -skipTrash /${schema}/SF${scale}
fi
###

#Creating schema Directory (if not existent)
echo "Creating schema Directory (if not existent)"
hadoop fs -mkdir -p /${schema}/SF${scale}

STARTTIME=`date +%s`
echo "Start time of the Drill Query "`date +%H:%M:%S`

#for tbl in `cat tpch_tables`; do
#    echo "Writing table - $tbl"

#SKIP::alter session set \`planner.width.max_per_node\`=${maxWidthToUse};

#sqlline -u "jdbc:drill:schema=dfs.${schema}:drillbit=$hostname:31010;auth=MAPRSASL"  << EOF  &
#use dfs.${schema};
#create table ${tbl} as select * from dfs.\`/tpchView/SF$scale/${tbl}_csv$scale\`;
#EOF
#done

### WITH WAITING (THIS IS WORKAROUND - FIXING OOM ISSUE WHILE GENERATING / INSERTING DATA):::

for tbl in `cat tpch_tables`; do
    echo "Writing table - $tbl"

    #SKIP::alter session set \`planner.width.max_per_node\`=${maxWidthToUse};

    sqlline -u "jdbc:drill:schema=dfs.${schema}:drillbit=$hostname:31010;auth=MAPRSASL"  << EOF &
    use dfs.${schema};
    create table ${tbl} as select * from dfs.\`/tpchView/SF$scale/${tbl}_csv$scale\`;
EOF

    # Capture the PID of the sqlline process
    pid=$!

    # Wait for the sqlline process to complete
    wait $pid
done

wait;

echo "Exit code $?"
ENDTIME=`date +%s`
     
echo "Query time is: `expr $ENDTIME - $STARTTIME` sec"
