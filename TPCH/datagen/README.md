Preparation:
1. Ensure the prerequisites in root README of the test kit are completed.
2. Edit the file ../../utils/dfs.json_Template to have correct connection string
    and appropriate workspaces
3. Ensure workloads/ contains the needed workload files, with filename as tpch.workload.<SF>.lst
   where SF is the scale factor.  The file contains one row for each table in the format:
    <table code>  <table name>    <number of chunks>
   NOTE: if the file is not there, generateTPCH.sh will create one for you.
   
To create the data set and build the parquet database, for scale factor X:
./build_tpchParquetDB.sh X  

Possible values:

```
1
30
100
333
1000
3000
10000
```

e.g.:
```
./build_tpchParquetDB.sh 1
./build_tpchParquetDB.sh 30
./build_tpchParquetDB.sh 100
./build_tpchParquetDB.sh 333
./build_tpchParquetDB.sh 1000
./build_tpchParquetDB.sh 3000
./build_tpchParquetDB.sh 10000
```

#### Check the generated data in mapr-fs:

```
hadoop  fs -du -h /tpchParquet/
```

Example of output:

```
# hadoop  fs -du -h /tpchParquet/
1.1 G   1.1 G   /tpchParquet/SF1
33.1 G  33.1 G  /tpchParquet/SF30
110.2 G  110.2 G  /tpchParquet/SF100
367.0 G  367.0 G  /tpchParquet/SF333
```

