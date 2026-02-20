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
set auto-load safe-path /home/pf9/build/

end
