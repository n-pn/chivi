const purge = require('@fullhuman/postcss-purgecss')
const svelte = require('purgecss-from-svelte')
const autoprefixer = require('autoprefixer')
const cssnano = require('cssnano')

const mode = process.env.NODE_ENV
const prod = mode === 'production'

module.exports = {
  plugins: [
    autoprefixer(),
    prod && cssnano({ preset: 'default' }),
    prod &&
      purge({
        content: ['./src/**/*.{svelte,html,svx,md}'],
        extractors: [
          {
            extractor: (content) => svelte.extract(content),
            extensions: ['svelte'],
          },
        ],
      }),
  ].filter(Boolean),
}
