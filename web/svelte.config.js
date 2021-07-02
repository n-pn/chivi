import preprocess from 'svelte-preprocess'
import node from '@sveltejs/adapter-node'
import { mdsvex } from 'mdsvex'
import breaks from 'remark-breaks'

import postcssConfig from './postcss.config.cjs'

import path from 'path'
import { fileURLToPath } from 'url'

const _cwd = path.dirname(fileURLToPath(import.meta.url))

const mdsvexConfig = {
  extensions: ['.svx', '.md'],
  smartypants: { dashes: 'oldschool' },
  remarkPlugins: [breaks],
  rehypePlugins: [],
  layout: path.resolve(_cwd, 'src/lib/layouts/Article.svelte'),
}

/** @type {import('@sveltejs/kit').Config} */
const config = {
  extensions: ['.svelte', '.svx', '.md'],
  preprocess: [
    preprocess({
      scss: {
        prependData: `@use "sass:math";\n@import "src/css/helpers";`,
        renderSync: true,
      },
      postcss: postcssConfig,
    }),
    mdsvex(mdsvexConfig),
  ],
  kit: {
    adapter: node(),
    target: '#svelte',
    hostHeader: 'X-Forwarded-Host',
    vite: {
      resolve: {
        alias: {
          $api: path.resolve(_cwd, 'src/api'),
          $utils: path.resolve(_cwd, 'src/utils'),
        },
      },
      server: {
        proxy: { '/covers': 'http://localhost:5010' },
      },
    },
  },
}

export default config
