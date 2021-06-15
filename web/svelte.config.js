import preprocess from 'svelte-preprocess'
import node from '@sveltejs/adapter-node'
import { mdsvex } from 'mdsvex'
import breaks from 'remark-breaks'

import postcssConfig from './postcss.config.cjs'

import path from 'path'
import { fileURLToPath } from 'url'

const prod = process.env.NODE_ENV == 'production'
const _cwd = prod ? './' : path.dirname(fileURLToPath(import.meta.url))

const mdsvexConfig = {
  extensions: ['.svx', '.md'],
  smartypants: { dashes: 'oldschool' },
  remarkPlugins: [breaks],
  rehypePlugins: [],
  // layout: path.resolve(_cwd, 'src/lib/parts/Layout.svelte'),
}

/** @type {import('@sveltejs/kit').Config} */
const config = {
  extensions: ['.svelte', '.svx', '.md'],
  preprocess: [
    preprocess({
      scss: {
        includePaths: [path.resolve(_cwd, 'src/css')],
        prependData: `@use "sass:math";\n@import "helpers";`,
      },
      postcss: postcssConfig,
    }),
    mdsvex(mdsvexConfig),
  ],
  kit: {
    adapter: node(),
    target: '#svelte',
    vite: {
      resolve: {
        alias: {},
      },
    },
  },
}

export default config
