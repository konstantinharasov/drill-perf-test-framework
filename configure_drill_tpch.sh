#!/bin/bash

# Add hostname to drillbits.lst
# shellcheck disable=SC2005
echo "$(hostname -f)" >> drillbits.lst