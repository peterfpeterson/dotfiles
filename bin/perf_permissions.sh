#!/bin/bash

# Taken from Milian Wolf's talk "Linux perf for Qt developers"
sudo mount -o remount,mode=755 /sys/kernel/debug
sudo mount -o remount,mode=755 /sys/kernel/debug/tracing
echo "0" | sudo tee /proc/sys/kernel/kptr_restrict
echo "-1" | sudo tee /proc/sys/kernel/perf_event_paranoid
sudo chown `whoami` /sys/kernel/debug/tracing/uprobe_events
sudo chmod a+rw /sys/kernel/debug/tracing/uprobe_events

# Taken from vtune's docs
# https://www.intel.com/content/www/us/en/docs/vtune-profiler/user-guide/2023-0/linux-targets.html
sudo sysctl -w kernel.yama.ptrace_scope=0
