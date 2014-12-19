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
    atom.config.observe 'linter-luacheck.globals', => @updateCommand()
    atom.config.observe 'linter-luacheck.ignore', => @updateCommand()

  destroy: ->
    atom.config.unobserve 'linter-luacheck.executable'
    atom.config.unobserve 'linter-luacheck.globals'
    atom.config.unobserve 'linter-luacheck.ignore'

  # Sets the command based on config options
  updateCommand: ->
    cmd = [atom.config.get 'linter-luacheck.executable']
    cmd.push '--no-color'
    @cmd = cmd

    @globals = atom.config.get 'linter-luacheck.globals'
    @ignore = atom.config.get 'linter-luacheck.ignore'

  # Override to add --globals args which must put after files
  getCmdAndArgs: (filePath) ->
    {command, args} = super (filePath)
    if @globals and @globals.length > 0
        args.push '--globals'
        args = args.concat @globals
    if @ignore and @ignore.length > 0
        args.push '--ignore'
        args = args.concat @ignore

    return {
      command: command,
      args: args
    }



module.exports = LinterLuacheck
