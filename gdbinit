#
# gdb initialization file.
#
# Sets better gdb defaults and loads pretty printers
#

# gdb commands
set print pretty on
set print object on
set print static-members on
set print vtbl on
set print demangle on
set demangle-style gnu-v3
set print sevenbit-strings off
set breakpoint pending on

# python pretty printers
python
import os
import sys
sys.path.insert(0, os.path.join(os.path.expanduser("~"), ".gdb/python"))
from libcxx.v1.printers import register_libcxx_printers
import boost

register_libcxx_printers (None)
boost.register_printers(boost_version=(1,53,0))

end
