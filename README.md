# linter-luacheck

Mac                     |Windows                 |Linux
:----------------------:|:----------------------:|:--------------------------:
[![mac-badge][]][mac-ci]|[![win-badge][]][win-ci]|[![linux-badge][]][linux-ci]

This package will lint your opened Lua files in Atom, using [luacheck](https://github.com/mpeterv/luacheck).

## Installation

* Install [luacheck](https://github.com/mpeterv/luacheck).
* `$ apm install linter` (if you don't have [AtomLinter/Linter](https://github.com/AtomLinter/Linter) installed).
* `$ apm install linter-luacheck`

## Configuration

Atom -> Preferences... -> Packages -> linter-luacheck -> Settings:

* **Executable** Path to your luacheck executable.

To config luacheck, you may:

Use [config file](http://luacheck.readthedocs.io/en/0.12.0/config.html) named `.luacheckrc` (in project root and/or Lua source dirs).

Example `.luacheckrc` at project root:

```lua
files['*.rockspec'].global = false
files['.luacheckrc'].global = false
files['spec/*_spec.lua'].std = 'min+busted'
```

Or use luacheck [inline options](http://luacheck.readthedocs.io/en/0.12.0/inline.html).

Example `project/luafile.lua`:

```lua
local lib = {}
function lib.add(self, a, b) -- luacheck: ignore self
  return a+b
end
```

## Contribute

Bugs, ideas and pull requests please go to [AtomLinter/linter-luacheck](https://github.com/AtomLinter/linter-luacheck).



[mac-badge]: https://travis-ci.org/AtomLinter/linter-luacheck.svg?branch=master
[mac-ci]: https://travis-ci.org/AtomLinter/linter-luacheck
[win-badge]: https://ci.appveyor.com/api/projects/status/uk8gd88k1af3ga5a?svg=true
[win-ci]: https://ci.appveyor.com/project/xpol/linter-luacheck
[linux-badge]: https://circleci.com/gh/AtomLinter/linter-luacheck.svg?style=shield
[linux-ci]: https://circleci.com/gh/AtomLinter/linter-luacheck
