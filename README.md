# linter-luacheck

This package will lint your opened Lua files in Atom, using [luacheck](https://github.com/mpeterv/luacheck).

## Installation

* Install [luacheck](https://github.com/mpeterv/luacheck).
* `$ apm install linter` (if you don't have [AtomLinter/Linter](https://github.com/AtomLinter/Linter) installed).
* `$ apm install linter-luacheck`

## Configuration

Atom -> Preferences... -> Packages -> linter-luacheck -> Settings:

* **Executable** Path to your luacheck executable.
* **Globals** Add more globals names to standard ones, separated by comma, eg `jit, bit`.
* **Ignore** Ignore warnings related to these variables names, separated by comma, eg `self, myvar`.

## Other available linters

There are other linters available - take a look at the linters [mainpage](https://github.com/AtomLinter/Linter).
