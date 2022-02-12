import preprocess from 'svelte-preprocess'
import node from '@sveltejs/adapter-node'
import { mdsvex } from 'mdsvex'
import breaks from 'remark-breaks'
import path from 'path'
import { fileURLToPath } from 'url'

const _cwd = path.dirname(fileURLToPath(import.meta.url))

const mdsvexConfig = {
  extensions: ['.svx', '.md'],
  smartypants: { dashes: 'oldschool' },
  remarkPlugins: [breaks],
  rehypePlugins: [],
  layout: path.resolve(_cwd, 'src/gui/sects/MdPost.svelte'),
}

/** @type {import('@sveltejs/kit').Config} */
export default {
  extensions: ['.svelte', '.svx', '.md'],
  preprocess: [
    preprocess({
      scss: {
        prependData: `@use "sass:math";\n@use "sass:list";\n@import "essence";`,
        includePaths: [path.resolve(_cwd, 'src/styles')],
        renderSync: true,
      },
      postcss: true,
    }),
    mdsvex(mdsvexConfig),
  ],
  kit: {
    adapter: node(),
    methodOverride: {
      allowed: ['PATCH', 'DELETE'],
    },
    vite: {
      resolve: {
        alias: {
          $api: path.resolve(_cwd, 'src/api'),
          $gui: path.resolve(_cwd, 'src/gui'),
          $utils: path.resolve(_cwd, 'src/utils'),
          $types: path.resolve(_cwd, 'src/types'),
        },
      },
      server: {
        proxy: { '/covers': 'http://localhost:5010' },
      },
    },
  },
}
