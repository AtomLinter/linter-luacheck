'use babel';

import { join } from 'path';
import { beforeEach, it } from 'jasmine-fix'; // eslint-disable-line import/no-extraneous-dependencies
import linterLuacheck from '../lib/init';

const emptyPath = join(__dirname, 'fixtures', 'empty.lua');
const goodPath = join(__dirname, 'fixtures', 'good.lua');
const warningPath = join(__dirname, 'fixtures', 'warning.lua');
const errorPath = join(__dirname, 'fixtures', 'error.lua');

const errorStr = "expected identifier near 'local'";
const warningStr = "unused argument 'self'";

describe('The luacheck provider for Linter', () => {
  const lint = linterLuacheck.provideLinter().lint;

  beforeEach(async () => {
    atom.workspace.destroyActivePaneItem();
    await atom.packages.activatePackage('linter-luacheck');
  });

  it('should be in the packages list', () =>
    expect(atom.packages.isPackageLoaded('linter-luacheck')).toBe(true)
  );

  it('should be an active package', () =>
    expect(atom.packages.isPackageActive('linter-luacheck')).toBe(true)
  );

  it('finds nothing wrong with an empty file', async () => {
    const editor = await atom.workspace.open(emptyPath);
    const result = await lint(editor);

    expect(result.length).toEqual(0);
  });

  it('finds nothing wrong in good.lua', async () => {
    const editor = await atom.workspace.open(goodPath);
    const result = await lint(editor);

    expect(result.length).toEqual(0);
  });

  it('finds warning in warning.lua', async () => {
    const editor = await atom.workspace.open(warningPath);
    const result = await lint(editor);

    expect(result.length).toEqual(1);
    expect(result[0].severity).toBeDefined();
    expect(result[0].severity).toEqual('warning');
    expect(result[0].excerpt).toBeDefined();
    expect(result[0].excerpt).toEqual(warningStr);
    expect(result[0].location.file).toBeDefined();
    expect(result[0].location.file).toMatch(/.+warning\.lua$/);
    expect(result[0].location.position).toBeDefined();
    expect(result[0].location.position.length).toEqual(2);
    expect(result[0].location.position).toEqual([[2, 10], [2, 11]]);
  });

  it('finds error in error.lua', async () => {
    const editor = await atom.workspace.open(errorPath);
    const result = await lint(editor);

    expect(result.length).toEqual(1);
    expect(result[0].severity).toBeDefined();
    expect(result[0].severity).toEqual('error');
    expect(result[0].excerpt).toBeDefined();
    expect(result[0].excerpt).toEqual(errorStr);
    expect(result[0].location.file).toBeDefined();
    expect(result[0].location.file).toMatch(/.+error\.lua$/);
    expect(result[0].location.position).toBeDefined();
    expect(result[0].location.position.length).toEqual(2);
    expect(result[0].location.position).toEqual([[2, 6], [2, 11]]);
  });
});
