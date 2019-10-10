#!/bin/sh
echo "$(~/bin/daysuntil 2019-10-13) days - TN Toughman" > ~/.daysuntil.deadlines
echo "$(~/bin/daysuntil 2019-10-14) days - ICANS conference" >> ~/.daysuntil.deadlines
echo "$(~/bin/daysuntil 2019-10-22) days - HFIR startup" >> ~/.daysuntil.deadlines
echo "$(~/bin/daysuntil 2020-03-29) days - Knoxville Marathon" >> ~/.daysuntil.deadlines
echo "$(~/bin/daysuntil 2020-04-12) days - Python2 is dead" >> ~/.daysuntil.deadlines

# sort the file just in case things aren't already in order
sort ~/.daysuntil.deadlines -n -o ~/.daysuntil.deadlines
