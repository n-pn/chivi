// vite.config.js
import { sveltekit } from '@sveltejs/kit/vite'
// import autoImport from 'sveltekit-autoimport'

import path from 'path'
import { fileURLToPath } from 'url'
const _cwd = path.dirname(fileURLToPath(import.meta.url))

/** @type {import('vite').UserConfig} */
const config = {
  plugins: [
    // autoImport({
    //   components: [{ name: './src/gui/atoms', flat: true }],
    //   module: {
    //     svelte: ['onMount', 'createEventDispatcher'],
    //   },
    //   include: ['**/*.svelte'],
    //   exclude: ['**/node_modules/**'],
    // }),
    sveltekit(),
  ],
  resolve: {
    alias: {
      $api: path.resolve(_cwd, 'src/api'),
      $gui: path.resolve(_cwd, 'src/gui'),
      $utils: path.resolve(_cwd, 'src/utils'),
      $types: path.resolve(_cwd, 'src/types'),
    },
  },
  server: {
    proxy: {
      '/api': 'http://localhost:5010',
      '/_db': 'http://localhost:5010',
      '/_wn': 'http://localhost:5020',

      '/_m0': 'http://localhost:5100',
      '/_m1': 'http://localhost:5110',
      '/_m2': 'http://localhost:5120',

      '/_sp': 'http://localhost:5300',

      '/_ys': 'http://localhost:5400',
    },
  },
  vitePlugin: {
    experimental: { prebundleSvelteLibraries: true },
  },
}

export default config
