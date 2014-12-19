module.exports =
  config:
    executable:
      type: 'string'
      default: 'luacheck'
    rcfile:
      type: 'string'
      default: ''

  activate: ->
    console.log 'activate linter-luacheck'
