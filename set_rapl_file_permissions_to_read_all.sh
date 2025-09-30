#!/bin/bash

# Purpose: grant read access to RAPL energy files in /sys/class/powercap/intel-rapl:*/energy_uj

set -e  # Exit immediately if a command fails

# Check if script is run with sudo
if [[ "$EUID" -ne 0 ]]; then
    echo "Please run this script with sudo: sudo ./set_rapl_file_permissions_to_read_all.sh"
    exit 1
fi

chmod a+r /sys/class/powercap/intel-rapl:*/energy_uj

echo "All done!"
