'use babel';

// eslint-disable-next-line import/no-extraneous-dependencies, import/extensions
import { CompositeDisposable } from 'atom';

let path;
let helpers;

const pattern = '.+:(?<line>\\d+):(?<col>\\d+)-(?<colEnd>\\d+):'
  + ' \\((?<type>[EW])\\d+\\) (?<message>.*)';

function loadDeps() {
  if (!helpers) {
    helpers = require('atom-linter');
  }
  if (!path) {
    path = require('path');
  }
}

function checkedOption(params, opt, args) {
  if (args.length > 0) {
    params.push(opt);
    return params.concat(args);
  }

  return params;
}

function reportToMessage(report, file) {
  const end = report.range[1];
  end[1] += 1;

  return {
    location: {
      file,
      position: [report.range[0], end]
    },
    severity: (report.type === 'E') ? 'error' : 'warning',
    excerpt: report.text
  };
}

export default {
  activate() {
    this.idleCallbacks = new Set();

    let depCallbackID;
    const installLinterLuacheckDeps = () => {
      this.idleCallbacks.delete(depCallbackID);

      require('atom-package-deps').install('linter-luacheck');
      loadDeps();
    };
    depCallbackID = window.requestIdleCallback(installLinterLuacheckDeps);

    this.idleCallbacks.add(depCallbackID);

    // This should be removed at a later point
    // It's here to ease the transition to the new version.
    const oldPath = atom.config.get('linter-luacheck.executable');
    if (oldPath !== undefined) {
      atom.config.unset('linter-luacheck.executable');
      if (oldPath !== 'luacheck') {
        // If the old config wasn't set to the default migrate it over
        atom.config.set('linter-luacheck.executablePath', oldPath);
      }
    }

    this.subscriptions = new CompositeDisposable();

    this.subscriptions.add(
      atom.config.observe('linter-luacheck.executablePath', (value) => {
        this.executablePath = value;
      }),
      atom.config.observe('linter-luacheck.ignore', (value) => {
        this.ignore = value;
      }),
      atom.config.observe('linter-luacheck.globals', (value) => {
        this.globals = value;
      }),
      atom.config.observe('linter-luacheck.standards', (value) => {
        this.standards = value;
      })
    );
  },

  deactivate() {
    this.idleCallbacks.forEach(callbackID => window.cancelIdleCallback(callbackID));
    this.idleCallbacks.clear();

    this.subscriptions.dispose();
  },

  makeParameters(file) {
    let params = [
      '-', '--no-color', '--codes',
      '--ranges', `--filename=${file}`
    ];

    params = checkedOption(params, '--globals', this.globals);
    params = checkedOption(params, '--ignore', this.ignore);

    if (this.standards.length > 0) {
      params.push('--std');
      params.push(this.standards.join('+'));
    }

    return params;
  },

  provideLinter() {
    return {
      name: 'Luacheck',
      grammarScopes: ['source.lua'],
      scope: 'file',
      lintsOnChange: true,

      lint: async (editor) => {
        const file = editor.getPath();
        const text = editor.getText();

        if (!file) {
          return null;
        }

        const params = this.makeParameters(file);

        loadDeps();

        const stdout = await helpers.exec(this.executablePath, params, {
          cwd: path.dirname(file),
          stdin: text,
          ignoreExitCode: true
        });

        return helpers.parse(stdout, pattern).map(v => reportToMessage(v, file));
      }
    };
  }
};
