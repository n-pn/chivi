// vite.config.js
import { sveltekit } from '@sveltejs/kit/vite'
import { loadEnv, defineConfig } from 'vite'

import path from 'path'
import { fileURLToPath } from 'url'

const _cwd = path.dirname(fileURLToPath(import.meta.url))

const dev = process.env['ENV'] == 'dev'
const env = loadEnv('dev', _cwd)

const proxy = {
  '/_db': `http://${env.VITE_BE_HOST}`,
  '/_wn': `http://${env.VITE_WN_HOST}`,

  '/_rd': `http://${env.VITE_RD_HOST}`,

  '/_m1': `http://${env.VITE_M1_HOST}`,
  '/_ai': `http://${env.VITE_AI_HOST}`,

  '/_sp': `http://${env.VITE_SP_HOST}`,
  '/_ys': `http://${env.VITE_YS_HOST}`,
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
