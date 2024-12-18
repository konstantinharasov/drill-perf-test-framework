#!/bin/bash

# Add hostname to drillbits.lst
# shellcheck disable=SC2005
echo -n "$(hostname -i)" > drillbits.lst
