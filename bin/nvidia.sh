#!/usr/bin/env bash

OUTPUT_FILE=~/.cache/nvidia_conky.txt

if [ $(lsmod | grep 'nvidia' -c) ]; then
    # GPU name
    #nvidia-smi --query-gpu=name --format=csv,noheader > "${OUTPUT_FILE}"

    # ask for information
    EVERYTHING=( $(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.free,memory.total --format=noheader,nounits --format=noheader,nounits | sed 's/,/ /g') )
    # in percent
    UTILIZATION="${EVERYTHING[0]}"
    # in C
    TEMPERATURE="${EVERYTHING[1]}"
    # in MiB
    MEMORY_USED="${EVERYTHING[2]}"
    MEMORY_FREE="${EVERYTHING[3]}"
    MEMORY_TOTAL="${EVERYTHING[4]}"

    # write everything out
    echo "\${color2}Temperature\$color\${alignr}${TEMPERATURE}°C"
    echo "\${color2}Utilization\$color\${alignr}${UTILIZATION}%"
    echo "\${color2}Memory\$color\${alignr}${MEMORY_USED} + ${MEMORY_FREE} = ${MEMORY_TOTAL}MiB"
else
    echo OFF > "${OUTPUT_FILE}"
fi
