'use babel';

import { parse, exec } from 'atom-linter';
import { dirname, extname } from 'path';

const isWindows = (/^win/).test(process.platform);
const pattern = '.+:(?<line>\\d+):(?<col>\\d+)-(?<colEnd>\\d+):' +
  ' \\((?<type>[EW])\\d+\\) (?<message>.*)';

const checkedAppend = function checkedAppend(parameters, opt, args) {
  if (args.length > 0) {
    parameters.push(opt);
    return parameters.concat(args);
  }

  return parameters;
};

const makeParameters = function makeParameters(globals, ignore, file) {
  let parameters = [
    '-', '--no-color', '--codes',
    '--ranges', `--filename=${file}`
  ];

  parameters = checkedAppend(parameters, '--globals', globals);
  parameters = checkedAppend(parameters, '--ignore', ignore);

  return parameters;
};

const reportToMessage = function reportToMessage(report, file) {
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
};

export default {
  activate() {
    require('atom-package-deps').install('linter-luacheck');
  },

  provideLinter() {
    return {
      name: 'Luacheck',
      grammarScopes: ['source.lua'],
      scope: 'file',
      lintsOnChange: true,

      lint: async (editor) => {
        const globals = atom.config.get('linter-luacheck.globals');
        const ignore = atom.config.get('linter-luacheck.ignore');
        let executable = atom.config.get('linter-luacheck.executable');
        console.log(globals, ignore, executable);

        if (isWindows && extname(executable) !== '.bat') {
          executable += '.bat';
        }

        const file = editor.getPath();

        const parameters = makeParameters(globals, ignore, file);

        const stdout = await exec(executable, parameters, {
          cwd: dirname(file),
          stdin: editor.getText() || '\n',
          stream: 'stdout',
          ignoreExitCode: true
        });

        return parse(stdout, pattern).map(v => reportToMessage(v, file));
      }
    };
  }
};
