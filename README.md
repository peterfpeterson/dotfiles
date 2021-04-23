# dotfiles

This my configuration files as managed by [dotbot](https://github.com/anishathalye/dotbot).

Before doing anything initialize/update the submodules

```bash
git submodule init
git submodule update
cd todo.actions.d
git submodule init
git submodule update
cd -
```

Then run

```bash
$ ./install
```

Re-running should not do anything.

Things not covered:
-------------------

* Things in `tools` are not run
* `sway-wrapper` which sets up environment variables for applications to use wayland
* [gnome-terminal-colors-solarized](https://github.com/Anthony25/gnome-terminal-colors-solarized) - run `./gnome-terminal-colors-solarized/set_dark.sh` and go through the process
* `./configure-gnome-terminal` is not automatically run
* Split [vpn tunneling](https://code.ornl.gov/rwp/ornl-openconnect)
* Copying `sys/etc/ld.so.conf.d/usr-local.conf` into `/etc/ld.so.conf.d/` and running `ldconfig`. This adds `/usr/local/lib` to your `LD_LIBRARY_PATH`. If ldconfig gives a message about `/etc/ld.so.conf` missing, copy that file over as well.

Git ssh keys
------------

After running `ssh-keygen`, the key can be copied to the clipboard using

```bash
$ xclip -sel c < ~/.ssh/id_rsa.pub
```

To update the individual tools
------------------------------

These instructions are [inspired/modified from mantid](https://github.com/mantidproject/paraview-build/blob/master/buildscript).

* `git submodule foreach git fetch -p -t`
* go into each (updated) submodule and decide whether or not to move what revision to use. This is generally done by either:
  * `git tag` to list the tags then `git checkout tagname`
  * `git rebase -v origin/master`
* `git commit <submodule directory names without a trailing slash>`

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](http://opensource.org/licenses/MIT)
