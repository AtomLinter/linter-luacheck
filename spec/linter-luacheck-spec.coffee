describe 'The luacheck provider for Linter', ->
  lint = require('../lib/init').provideLinter().lint

  openFixtureFileInAtom = (file) ->
    return atom.workspace.open(__dirname + '/fixtures/' + file)

  beforeEach ->
    atom.workspace.destroyActivePaneItem()
    waitsForPromise ->
      return atom.packages.activatePackage('linter-luacheck')

  it 'should be in the packages list', ->
    return expect(atom.packages.isPackageLoaded('linter-luacheck')).toBe true

  it 'should be an active package', ->
    return expect(atom.packages.isPackageActive('linter-luacheck')).toBe true

  it 'finds nothing wrong with an empty file', ->
    waitsForPromise ->
      return openFixtureFileInAtom('empty.lua').then (editor) ->
        return lint(editor).then (messages) ->
          expect(messages.length).toEqual 0

  it 'finds nothing wrong in good.lua', ->
    waitsForPromise ->
      return openFixtureFileInAtom('good.lua').then (editor) ->
        return lint(editor).then (messages) ->
          expect(messages.length).toEqual 0

  it 'finds warning in warning.lua', ->
    waitsForPromise ->
      return openFixtureFileInAtom('warning.lua').then (editor) ->
        return lint(editor).then (messages) ->
          expect(messages.length).toEqual 1
          expect(messages[0].severity).toBeDefined()
          expect(messages[0].severity).toEqual('warning')
          expect(messages[0].excerpt).toBeDefined()
          expect(messages[0].excerpt).toEqual("unused argument 'self'")
          expect(messages[0].location.file).toBeDefined()
          expect(messages[0].location.file).toMatch(/.+warning\.lua$/)
          expect(messages[0].location.position).toBeDefined()
          expect(messages[0].location.position.length).toEqual(2)
          expect(messages[0].location.position).toEqual([[2, 10], [2, 11]])

  it 'finds error in error.lua', ->
    waitsForPromise ->
      return openFixtureFileInAtom('error.lua').then (editor) ->
        error_str = "expected identifier near 'local'"

        return lint(editor).then (messages) ->
          expect(messages.length).toEqual 1
          expect(messages[0].severity).toBeDefined()
          expect(messages[0].severity).toEqual('error')
          expect(messages[0].excerpt).toBeDefined()
          expect(messages[0].excerpt).toEqual(error_str)
          expect(messages[0].location.file).toBeDefined()
          expect(messages[0].location.file).toMatch(/.+error\.lua$/)
          expect(messages[0].location.position).toBeDefined()
          expect(messages[0].location.position.length).toEqual(2)
          expect(messages[0].location.position).toEqual([[2, 6], [2, 11]])
