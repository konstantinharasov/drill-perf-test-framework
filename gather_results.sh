#!/bin/bash

total_time_ms=0
echo "Query - TOTAL TIME" > result.txt

for i in {01..20}; do
  dir="Q${i}"
  if [ -d "$dir" ]; then
    log_file="${dir}/${dir}.log"
    if [ -f "$log_file" ]; then
      total_time=$(grep "TOTAL TIME" "${log_file}" | awk -F ': ' '{print $2}' | sed 's/msec//')
      if [ -n "${total_time}" ]; then
        total_time_ms_dir=${total_time}
        total_time_ms=$((total_time_ms + total_time_ms_dir))
        total_time_s=$((total_time_ms_dir / 1000))
        hours=$((total_time_s / 3600))
        minutes=$(( (total_time_s % 3600) / 60 ))
        seconds=$((total_time_s % 60))
        echo "${dir} - TOTAL TIME : ${hours}h ${minutes}m ${seconds}s" >> result.txt
      fi
    fi
  fi
done

total_time_s=$((total_time_ms / 1000))
hours=$((total_time_s / 3600))
minutes=$(( (total_time_s % 3600) / 60 ))
seconds=$((total_time_s % 60))
echo "OVERALL - TOTAL TIME : ${hours}h ${minutes}m ${seconds}s" >> result.txt