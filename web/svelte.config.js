const path = require('path')
const prep = require('svelte-preprocess')

module.exports = {
  preprocess: prep({
    // babel: {
    //   presets: [
    //     [
    //       '@babel/preset-env',
    //       {
    //         loose: true,
    //         modules: false,
    //         targets: { esmodules: true },
    //       },
    //     ],
    //   ],
    // },
    defaults: { style: 'scss', script: 'typescript' },
    sourceMap: process.env.NODE_ENV === 'development',
    css: { includePaths: ['src', 'node_modules'] },
    scss: {
      includePaths: [
        path.resolve(__dirname, 'src/styles'),
        path.resolve(__dirname, 'node_modules'),
      ],
      prependData: "@import 'essence';",
    },
    typescript: { transpileOnly: true },
  }),
}
