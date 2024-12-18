# Performance Test Framework for Apache Drill

Performance Test Framework for SQL on Hadoop technologies. Currently supports [Apache Drill](http://drill.apache.org/), a schema-free SQL query engine for Hadoop, NoSQL and cloud storage.

The framework is built for regression testing with focus on query performance. Test cases include customized industry standard benchmarks such as TPC-H and TPC-DS. A subset of these tests are used by the Apache Drill community for pre-commit and pre-release criteria.

## Overview
 1. Clone the repository
 2. Configure test environment
 3. Review tests
 4. Build test framework
 5. Execute tests

### Clone the repository
```
 git clone https://github.com/konstantinharasov/drill-perf-test-framework.git
```
Refer to [Github documentation](https://help.github.com/articles/cloning-a-repository) on how to clone a repository. 

### Configure test environment
 1. The test framework requires a distributed file system (MapR-FS) to be configured. 
It also requires that Drill services to be setup on a clustered environment. 
Refer to [Drill documentation](http://drill.apache.org/docs/installing-drill-in-distributed-mode) for details on how to setup Drill.
 2. Ensure passwordless SSH is enabled among the server nodes in the cluster. 
 3. Ensure the following are installed:
	- clush
```
yum --enablerepo=epel install clustershell
```
          also ensure that /etc/clustershell/group contains appropriate groups, such as 
	       -- "all":  for all the nodes that will run drillbit
               -- "remoteDrillbits": for all the remote nodes that are running drillbits 
	  
	- dstat
```
yum install -y dstat
```
	
 4. Edit PerfTestEnv.conf to set needed environmental variables

make sure classpath in this file specified as following:

```
DRILL_JDBC_CLASSPATH=`find ${DRILL_HOME} -name "*jar"|sed -r 's/\/[^\/]+$/\/\*/'|sort|uniq|tr '\n' ':'`${DRILL_HOME}/conf:$TestKitDir/driver/*:/opt/mapr/drill/drill-$gitv/jars/drill-auth-mechanism-maprsasl-*.jar
```

 5. Edit drillbits.lst to contain all the IPs of the drillbit nodes.

> for a single node, run the script `configure_drill_tpch.sh`

```
bash configure_drill_tpch.sh
```

 6. Build the databases  
   	- Currently, the kit includes data generation scripts for TPCH and TPCDS databases and some queries for those benchmark tests.
       See READMEs in TPCH/datagen and TPCDS/datagen for how to generate data and build database for those tests (only parquet files are implemented now).
       - NOTE: in this version of TCPH framework only TPCH/datagen is supported.
      
	- If database is already built, ensure the connection string and workspaces are defined in storage plugin as specified in utils/dfs.json_Template.
 7. [TO DO] Copy stats collection scripts to remote drillbit nodes (currently,TCPH tests support only single-node RUN).
```
./CopyScriptsToRemote.sh
```
 8. Build the driver
```
cd driver
./buildDriver.sh
```

### Review tests
Each test case is specified in a directory structure:
```
   benchmark_name (e.g., TPCH, TPCDS)
      |_ datagen
      |_ Queries
```
 datagen contains the needed resources for building the database

### Execute tests
1. Edit `params.conf` to reflect what to be run.

Make sure the following variables are specified:

```
export scaleFactor=30
```

Make sure, that specified value was used previously to generate data and the data present in MapR-FS:

```
# hadoop  fs -du -h /tpchParquet/
1.1 G   1.1 G   /tpchParquet/SF1
33.1 G  33.1 G  /tpchParquet/SF30   <--- 30GB data set. Can be specified as a scaleFactor to run tests against.
```

2. Launch TPCH tests:

```
./run.sh
```

> Run with nohup:
 
```
nohup bash run.sh &> run_TPCH_DATE.log & echo $! > reset1.pid
```

### logs and results
results will be located at log/\<runid\>\_\<gitCommitId\>\_\<benchmark\>\_\<timestamp\>/
For each query the following metrics are collected, e.g.:
```
[STAT] Rows Fetched : 21842
[STAT] Time to load queries : 3 msec
[STAT] Time to register Driver : 632 msec
[STAT] Time to connect : 1045 msec
[STAT] Time to alter session : 0 msec
[STAT] Time to prep Statement  : 3 msec
[STAT] Time to execute query : 24818 msec
[STAT] Time to get query ID : 0 msec
[STAT] Time to fetch 1st Row : 36858 msec
[STAT] Time to fetch All Rows : 37180 msec
[STAT] Time to disconnect : 3 msec
[STAT] TOTAL TIME : 61998 msec
```

To summarise a results after run, copy `gather_results.sh` script to:

```
cp gather_results.sh log/<run_id>_<gitCommitId>_<benchmark>_<timestamp>/
```

and run it:

```
cd log/<run_id>_<gitCommitId>_<benchmark>_<timestamp>/
bash gather_results.sh
```

Example of the output:

```
cat result.txt

[... 7_e88fc92_TPCH_20241101_074115]# cat result.txt
Query - TOTAL TIME
Q01 - TOTAL TIME : 0h 0m 18s
Q03 - TOTAL TIME : 0h 0m 37s
Q04 - TOTAL TIME : 0h 0m 20s
Q05 - TOTAL TIME : 0h 1m 36s
Q06 - TOTAL TIME : 0h 0m 9s
Q07 - TOTAL TIME : 0h 2m 42s
Q08 - TOTAL TIME : 0h 0m 40s
Q09 - TOTAL TIME : 0h 1m 7s
Q10 - TOTAL TIME : 0h 1m 5s
Q11 - TOTAL TIME : 0h 0m 3s
Q12 - TOTAL TIME : 0h 0m 35s
Q13 - TOTAL TIME : 0h 0m 34s
Q14 - TOTAL TIME : 0h 0m 38s
Q15 - TOTAL TIME : 0h 0m 0s
Q16 - TOTAL TIME : 0h 0m 19s
Q17 - TOTAL TIME : 0h 0m 49s
Q18 - TOTAL TIME : 0h 0m 16s
Q19 - TOTAL TIME : 0h 2m 34s
Q20 - TOTAL TIME : 0h 1m 25s
OVERALL - TOTAL TIME : 0h 15m 56s
```
 
