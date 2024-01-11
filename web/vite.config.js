// vite.config.js
import { sveltekit } from '@sveltejs/kit/vite'
import { loadEnv, defineConfig } from 'vite'

import path from 'path'
import { fileURLToPath } from 'url'

const _cwd = path.dirname(fileURLToPath(import.meta.url))

const dev = process.env['ENV'] == 'dev'
const env = loadEnv('dev', _cwd)

const proxy = {
  '/_db': `http://127.0.0.1:${env.VITE_BE_PORT}`,
  '/_wn': `http://127.0.0.1:${env.VITE_WN_PORT}`,

  '/_rd': `http://127.0.0.1:${env.VITE_RD_PORT}`,

  '/_m1': `http://127.0.0.1:${env.VITE_M1_PORT}`,
  '/_ai': `http://127.0.0.1:${env.VITE_AI_PORT || 5121}`,

  '/_sp': `http://127.0.0.1:${env.VITE_SP_PORT}`,
  '/_ys': `http://127.0.0.1:${env.VITE_YS_PORT}`,
}

export default defineConfig({
  // css: {
  //   preprocessorOptions: {
  //     scss: {
  //       additionalData: `
  //         @use "sass:math";
  //         @use "sass:list";
  //         @use "essence" as *;
  //         `,
  //       includePaths: [path.resolve(_cwd, 'src/styles')],
  //     },
  //     postcss: true,
  //   },
  // },
  plugins: [sveltekit()],
  resolve: {
    alias: {
      $src: path.resolve(_cwd, 'src'),
      $api: path.resolve(_cwd, 'src/api'),
      $gui: path.resolve(_cwd, 'src/gui'),
      $utils: path.resolve(_cwd, 'src/utils'),
      $types: path.resolve(_cwd, 'src/types'),
    },
  },
  server: { host: 'localhost', proxy: dev && proxy },
  vitePlugin: { experimental: { prebundleSvelteLibraries: true } },
})
