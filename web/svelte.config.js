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
  layout: path.resolve(_cwd, 'src/lib/sects/MdPost.svelte'),
}

/** @type {import('@sveltejs/kit').Config} */
export default {
  extensions: ['.svelte', '.svx', '.md'],
  preprocess: [
    preprocess({
      scss: {
        prependData: `@use "sass:math";\n@use "sass:list";\n@import "essence";`,
        includePaths: [path.resolve(_cwd, 'src/css')],
        renderSync: true,
      },
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
          $atoms: path.resolve(_cwd, 'src/lib/atoms'),
          $molds: path.resolve(_cwd, 'src/lib/molds'),
          $parts: path.resolve(_cwd, 'src/lib/parts'),
          $sects: path.resolve(_cwd, 'src/lib/sects'),
          $utils: path.resolve(_cwd, 'src/lib/utils'),
        },
      },
      server: {
        proxy: { '/covers': 'http://localhost:5010' },
      },
    },
  },
}
