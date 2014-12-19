module.exports =
  config:
    executable:
      type: 'string'
      default: 'luacheck'
      description: 'The executable path to luacheck.'
    globals:
      type: 'array'
      default: []
      description: 'Add follow comma separated globals on top of standard ones.'
    ignore:
      type: 'array'
      default: []
      description: 'Ignore warnings related to these comma separated variables.'

  activate: ->
    console.log 'activate linter-luacheck'
