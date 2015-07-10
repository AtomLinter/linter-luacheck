{BufferedProcess, CompositeDisposable} = require 'atom'

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
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.config.observe 'linter-luacheck.executable',
      (executable) =>
        @executable = executable
    @subscriptions.add atom.config.observe 'linter-luacheck.globals',
      (globals) =>
        @globals = globals
    @subscriptions.add atom.config.observe 'linter-luacheck.ignore',
      (ignore) =>
        @ignore = ignore

  deactivate: ->
    @subscriptions.dispose()

  provideLinter: ->
    helpers = require('atom-linter')
    provider =
      grammarScopes: ['source.lua']
      scope: 'file'
      lintOnFly: true
      lint: (editor) =>
        file = editor.getPath()
        parameters = ['-', '--no-color']
        if @globals.length > 0
          parameters.push '--globals'
          parameters = parameters.concat @globals
        if @ignore.length > 0
          parameters.push '--ignore'
          parameters = parameters.concat @ignore
        pattern = /^.+:(\d+):(\d+): (.*)$/

        return helpers.exec(@executable, parameters,
          {stdin: editor.getText()}
        ).then (output) ->
          errors = []
          lines = output.split '\n'
          warnings = output.match(/(\d+) warnings/)
          type = if warnings and warnings[1] != '0' then 'Warning' else 'Error'
          for line in lines
            matches = line.match(pattern)
            if matches
              row = parseInt(matches[1])-1
              column = parseInt(matches[2])-1
              msg = matches[3]
              tm = msg.match(/near '([^']+)'/) or msg.match(/'([^']+)'/)
              token = tm and tm[1] or ''
              errors.push {
                type: type,
                text: msg,
                filePath: file,
                range: [[row,column],[row,column+token.length]]
              }
          return errors
