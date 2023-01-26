Executables are build for x64 systems. Add this bin directory to your path to prevent reference hell.

```sh
~/.bashrc

# This may not be accurate, check your path before adding this to your rc file
PATH="$PATH:$HOME/Saved Games/DCS.openbeta/Missions/DFCP-ME/tools/bin"
alias lua=lua54
```

You can now reference the distributable lua interpreter with `lua`.

Additional reference code written in this project can go in `../share/lua/5.4`, where it can be referenced in any script by it's name.
i.e. `mission_io.lua` can be imported with `require 'mission_io'`.

Dependencies not written in this project are added to `../share/lua/5.4/dep` and can be referenced with `require 'dep/mist_4_5_107'`.