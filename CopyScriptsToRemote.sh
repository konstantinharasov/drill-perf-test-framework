#!/bin/bash

set -x

source PerfTestEnv.conf
clush -g remoteDrillbits "mkdir -p $TestKitDir/utils"
clush -g remoteDrillbits --copy utils/*StatsCollection*sh --dest $TestKitDir/utils
