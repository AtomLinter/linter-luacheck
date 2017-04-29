helpers = null
path = null

isWindows = /^win/.test(process.platform)
pattern = '.+:(?<line>\\d+):(?<col>\\d+)-(?<colEnd>\\d+):' +
  ' \\((?<type>[EW])\\d+\\) (?<message>.*)'

checkedAppend = (parameters, opt, args) ->
  if args.length > 0
    parameters.push opt
    parameters.push(args...)

makeParameters = (globals, ignore, std, file) ->
  parameters = ['-', '--no-color', '--codes', '--ranges', "--filename=" + file]
  checkedAppend parameters, '--globals', globals
  checkedAppend parameters, '--ignore', ignore
  if std.length > 0
    parameters.push '--std'
    parameters.push(std.join '+')
  parameters

reportToMessage = (report, file) ->
  ++report.range[1][1]

  message =
    location:
      file: file
      position: report.range
    severity: if report.type == 'E' then 'error' else 'warning'
    excerpt: report.text

module.exports =
  config:
    executable:
      type: 'string'
      default: 'luacheck'
      description: 'The executable path to luacheck.'
    standard:
      type: 'array'
      default: []
      description: "List of comma separated standards.
        eg. `min, busted`"
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
      name: 'Luacheck'
      grammarScopes: ['source.lua']
      scope: 'file'
      lintsOnChange: true
      lint: (editor) ->
        helpers ?= require('atom-linter')
        path ?= require('path')
        file = editor.getPath()
        executable = atom.config.get 'linter-luacheck.executable'
        if isWindows and path.extname(executable) != '.bat'
          executable += '.bat'
        globals = atom.config.get 'linter-luacheck.globals'
        ignore = atom.config.get 'linter-luacheck.ignore'
        std = atom.config.get 'linter-luacheck.standard'

        parameters = makeParameters(globals, ignore, std, file)

        return helpers.exec(executable, parameters, {
          cwd: path.dirname file
          stdin: editor.getText() or '\n'
          stream: 'stdout'
          ignoreExitCode: true
        }).then (stdout) ->
          return helpers.parse(stdout, pattern).map (v)->
            reportToMessage(v, file)
