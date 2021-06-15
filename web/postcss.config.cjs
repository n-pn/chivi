const path = require('path')

const purge = require('@fullhuman/postcss-purgecss')
// const purgeSvelte = require('purgecss-from-svelte')
const autoprefixer = require('autoprefixer')
const cssnano = require('cssnano')

const mode = process.env.NODE_ENV
const prod = mode === 'production'

const purgeConfig = {
  content: [path.join(__dirname, './src/**/*.svelte')],
  keyframes: true,
  safelist: [/svelte-/],
  extractors: [
    {
      extractor: (content) => content.match(/[A-Za-z0-9-_:/]+/g) || [],
      extensions: ['svelte'],
    },
  ],
}

module.exports = {
  plugins: [
    autoprefixer,
    prod && cssnano({ preset: 'default' }),
    // prod && purge(purgeConfig),
  ].filter(Boolean),
}
