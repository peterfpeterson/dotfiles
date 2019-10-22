#!/bin/sh
echo "$(~/bin/daysuntil 2019-11-01) days - HFIR startup" > ~/.daysuntil.deadlines
echo "$(~/bin/daysuntil 2020-03-29) days - Knoxville Marathon" >> ~/.daysuntil.deadlines
echo "$(~/bin/daysuntil 2020-04-12) days - Python2 is dead" >> ~/.daysuntil.deadlines

# sort the file just in case things aren't already in order
sort ~/.daysuntil.deadlines -n -o ~/.daysuntil.deadlines
