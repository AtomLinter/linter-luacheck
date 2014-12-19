{exec} = require 'child_process'
linterPath = atom.packages.getLoadedPackage("linter").path
Linter = require "#{linterPath}/lib/linter"
{log, warn} = require "#{linterPath}/lib/utils"

class LinterLuacheck extends Linter
  # The syntax that the linter handles. May be a string or
  # list/tuple of strings. Names should be all lowercase.
  @syntax: 'source.lua'

  linterName: 'luacheck'

  regex: '^.+:(?<line>\\d+):(?<col>\\d+): (?<message>.*)$'
  regexFlags: 'm'

  constructor: (@editor) ->
    super @editor

    # sets @cwd to the dirname of the current file
    # if we're in a project, use that path instead
    @cwd = atom.project.path ? @cwd

    # Set to observe config options
    atom.config.observe 'linter-luacheck.executable', => @updateCommand()
    atom.config.observe 'linter-luacheck.rcfile', => @updateCommand()

  destroy: ->
    atom.config.unobserve 'linter-luacheck.executable'
    atom.config.unobserve 'linter-luacheck.rcfile'

  # Sets the command based on config options
  updateCommand: ->
    cmd = [atom.config.get 'linter-luacheck.executable']
    cmd.push '--no-color'

    rcfile = atom.config.get 'linter-luacheck.rcfile'
    if rcfile
      cmd.push "--config=#{rcfile}"

    @cmd = cmd


module.exports = LinterLuacheck
