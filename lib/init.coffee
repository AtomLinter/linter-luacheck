{BufferedProcess, CompositeDisposable} = require 'atom'

path = require 'path'

pattern = /^.+:(\d+):(\d+): (.*)$/

parseType = (stdout) ->
  m = stdout.match(/(\d+) error/)
  return if m and m[1] != '0' then 'Error' else 'Warning'

makeParameters = (globals, ignore) ->
  parameters = ['-', '--no-color', '--codes', '--ranges']
  if globals.length > 0
    parameters.push '--globals'
    parameters = parameters.concat globals
  if ignore.length > 0
    parameters.push '--ignore'
    parameters = parameters.concat ignore
  return parameters

makeReport = (buffer, matches, type, file) ->
  row = parseInt(matches[1])-1
  column = parseInt(matches[2])-1
  msg = matches[3]
  tm = msg.match(/near '([^']+)'/) or msg.match(/'([^']+)'/)
  token = tm and tm[1] or ' '
  offset = token.length
  if token == 'self' and buffer.lineForRow(row).indexOf('self') != column
    offset = 1

  return {
    type: type,
    text: msg,
    filePath: file,
    range: [[row,column],[row,column+offset]]
  }

module.exports =
  config:
    executable:
      type: 'string'
      default: 'luacheck'
      description: 'The executable path to luacheck.'
    globals:
      type: 'array'
      default: []
      description: "Add follow comma separated globals on top of standard ones.
        eg. `jit, bit`"
    ignore:
      type: 'array'
      default: []
      description: "Ignore warnings related to these comma separated variables.
        eg `self, myvar`"

  activate: ->
    console.log('active linter-luacheck')

  provideLinter: ->
    helpers = require('atom-linter')
    provider =
      grammarScopes: ['source.lua']
      scope: 'file'
      lintOnFly: true
      lint: (editor) ->
        file = editor.getPath()
        buffer = editor.getBuffer()
        executable = atom.config.get 'linter-luacheck.executable'
        globals = atom.config.get 'linter-luacheck.globals'
        ignore = atom.config.get 'linter-luacheck.ignore'

        return helpers.exec(executable, makeParameters(globals, ignore),
          {
            cwd: path.dirname file
            stdin: editor.getText()
          }
        ).then (output) ->
          regx = '.+:(?<line>[0-9]+):(?<col>[0-9]+)-(?<colEnd>[0-9]+): \\((?<type>.)[0-9]+\\) (?<message>.*)/'
          lines = output.split '\n'
          return helpers.parse(lines, regx)
