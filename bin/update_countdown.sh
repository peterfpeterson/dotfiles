#!/bin/sh
echo "$(~/bin/daysuntil 2019-08-05) days - First day of school" > ~/.daysuntil.deadlines
echo "$(~/bin/daysuntil 2019-08-23) days - Alex moves to MTSU" >> ~/.daysuntil.deadlines
echo "$(~/bin/daysuntil 2019-08-27) days - Smoky Mountain Conference" >> ~/.daysuntil.deadlines
echo "$(~/bin/daysuntil 2019-08-30) days - Bike to Elkmont" >> ~/.daysuntil.deadlines
echo "$(~/bin/daysuntil 2019-10-13) days - TN Toughman" >> ~/.daysuntil.deadlines
echo "$(~/bin/daysuntil 2020-03-29) days - Knoxville Marathon" >> ~/.daysuntil.deadlines
echo "$(~/bin/daysuntil 2020-04-12) days - Python2 is dead" >> ~/.daysuntil.deadlines

# sort the file just in case things aren't already in order
sort ~/.daysuntil.deadlines -n -o ~/.daysuntil.deadlines
