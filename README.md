# linter-luacheck

This package will lint your opened Lua files in Atom, using [luacheck](https://github.com/mpeterv/luacheck).

## Installation

* Install [luacheck](https://github.com/mpeterv/luacheck).
* `$ apm install linter` (if you don't have [AtomLinter/Linter](https://github.com/AtomLinter/Linter) installed).
* `$ apm install linter-luacheck`

## Configuration

Atom -> Preferences... -> Linter luacheck -> Settings have the follow settings:

* **Executable** Path to your luacheck executable.
* **Globals** Add more globals names to standard ones, separated by comma, eg `jit, bit`.
* **Ignore** Ignore warnings related to these variables names, separated by comma, eg `self, myvar`.

## Other available linters
There are other linters available - take a look at the linters [mainpage](https://github.com/AtomLinter/Linter).

## Changelog

### 0.3.0

- Added config globals and ignore
- Add config descriptions
- Removed config rcfile

### 0.2.0

- Published.

### 0.1.0

- Implemented first version of 'linter-luacheck'
