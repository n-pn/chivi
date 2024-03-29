import adapter from '@sveltejs/adapter-node'
// import { vitePreprocess } from '@sveltejs/vite-plugin-svelte'
import preprocess from 'svelte-preprocess'

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
  layout: path.resolve(_cwd, 'src/routes/hd/hd-layout.svelte'),
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
    adapter: adapter(),
    version: { pollInterval: 60000 },
    inlineStyleThreshold: 2048,
  },
  onwarn: (warning, handler) => {
    if (warning.code.startsWith('a11y')) return
    if (warning.code == 'vite-plugin-svelte-preprocess-many-dependencies')
      return
    handler(warning)
  },
}
