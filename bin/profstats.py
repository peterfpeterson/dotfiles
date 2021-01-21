#!/usr/bin/env python
######################################################################
# Reads python profile results using the Stats class
#
# https://docs.python.org/3/library/profile.html#the-stats-class
######################################################################
import pstats
from os import path

SORT_OPTIONS = ['cumulative', 'calls', 'time']
SORT_HELP = ''''What to sort the results by (default=%(default)s). The options are:
calls      - number of calls to the function
cumulative - accumulated time for the function
time       - internal time of the function
'''
DESCRIPTION = 'Show results from python profiling'
EPILOG = 'For more information on the sorting methods or restrictions see ' \
         'https://docs.python.org/3/library/profile.html#the-stats-class'

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description=DESCRIPTION, epilog=EPILOG)
    parser.add_argument('--filename', default='prof/combined.prof', help='File to parse (default="%(default)s")')
    parser.add_argument('--sortby', default=SORT_OPTIONS[0], choices=SORT_OPTIONS, help=SORT_HELP)
    parser.add_argument('--restrict',
                        '-r',
                        nargs='+',
                        default=list(),
                        metavar='RESTRICTION',
                        help='Add restrictions - TODO add docs')
    parser.add_argument('--callers',
                        nargs='+',
                        default=list(),
                        type=str,
                        metavar='RESTRICTION',
                        help='Print the callers of the selected file/function')
    parser.add_argument('--callees',
                        nargs='+',
                        default=list(),
                        type=str,
                        metavar='RESTRICTION',
                        help='Print the callees of the selected file/function')

    # parse the command line
    options = parser.parse_args()
    options.filename = path.abspath(options.filename)
    # verify options
    if not path.exists(options.filename):
        raise RuntimeError('File "{}" not found'.format(options.filename))

    print(options.restrict)

    print('Reading profile {}'.format(options.filename))

    stats = pstats.Stats(options.filename)
    if options.callers:
        stats.sort_stats(options.sortby).print_callers(*options.callers)
    elif options.callees:
        stats.sort_stats(options.sortby).print_callees(*options.callees)
    else:
        stats.sort_stats(options.sortby).print_stats(*options.restrict)
