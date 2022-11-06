// vite.config.js
import { sveltekit } from '@sveltejs/kit/vite'

import path from 'path'
import { fileURLToPath } from 'url'
const _cwd = path.dirname(fileURLToPath(import.meta.url))

/** @type {import('vite').UserConfig} */
const config = {
  plugins: [sveltekit()],
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
      '/_ys': 'http://localhost:5509',
      '/_mt': 'http://localhost:5502',
    },
  },
  vitePlugin: {
    experimental: {
      prebundleSvelteLibraries: true,
    },
  },
}

export default config
