const purge = require('@fullhuman/postcss-purgecss')
const autoprefixer = require('autoprefixer')
const cssnano = require('cssnano')

const prod = process.env.NODE_ENV === 'production'
const purging = process.env.PURGECSS === 'true'

const purgeConfig = {
  content: ['./src/**/*.{svelte,html,svx}'],
  keyframes: true,
  safelist: [/svelte-/, /tm-dark/, /x-v/],
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
    purging && purge(purgeConfig),
  ].filter(Boolean),
}
