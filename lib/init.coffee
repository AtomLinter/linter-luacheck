helpers = require('atom-linter')
path = require 'path'

isWindows = /^win/.test(process.platform)
pattern = '.+:(?<line>\\d+):(?<col>\\d+)-(?<colEnd>\\d+):' +
  ' \\((?<type>[EW])\\d+\\) (?<message>.*)'

checkedAppend = (parameters, opt, args) ->
  if args.length > 0
    parameters.push opt
    parameters.push(args...)

makeParameters = (globals, ignore, file) ->
  parameters = ['-', '--no-color', '--codes', '--ranges', "--filename=" + file]
  checkedAppend parameters, '--globals', globals
  checkedAppend parameters, '--ignore', ignore
  parameters

transformReport = (report, file) ->
  report.type = if report.type == 'E' then 'Error' else 'Warning'
  ++report.range[1][1]
  report.filePath = file
  report

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
    require('atom-package-deps').install()

  provideLinter: ->
    provider =
      grammarScopes: ['source.lua']
      scope: 'file'
      lintOnFly: true
      lint: (editor) ->
        file = editor.getPath()
        executable = atom.config.get 'linter-luacheck.executable'
        if isWindows and path.extname(executable) != '.bat'
          executable += '.bat'
        globals = atom.config.get 'linter-luacheck.globals'
        ignore = atom.config.get 'linter-luacheck.ignore'

        return helpers.exec(executable, makeParameters(globals, ignore, file), {
          cwd: path.dirname file
          stdin: editor.getText() or '\n'
          stream: 'both'
        }).then (output) ->
          return helpers.parse(output, pattern).map (v)->
            transformReport(v, file)
