const webpack = require('webpack')
const path = require('path')
const config = require('sapper/config/webpack.js')
const pkg = require('./package.json')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')

const mode = process.env.NODE_ENV
const dev = mode === 'development'

const alias = {
  svelte: path.resolve(__dirname, 'node_modules', 'svelte'),
  $src: path.resolve(__dirname, 'src'),
  $routes: path.resolve(__dirname, 'src/routes'),
  $atoms: path.resolve(__dirname, 'src', 'blocks/atoms'),
  $melds: path.resolve(__dirname, 'src', 'blocks/melds'),
  $parts: path.resolve(__dirname, 'src', 'blocks/parts'),
  $utils: path.resolve(__dirname, 'src/utils'),
}

const { preprocess } = require('./svelte.config')
const extensions = ['.mjs', '.js', '.json', '.svelte', '.html']
const mainFields = ['svelte', 'module', 'browser', 'main']

// postcss

const autoprefixer = require('autoprefixer')
const cssnano = require('cssnano')({ preset: 'default' })
const purgecss = require('@fullhuman/postcss-purgecss')({
  content: ['./src/**/*.html', './src/**/*.svelte'],
  keyframes: true,
  whitelistPatterns: [/svelte-/],
  defaultExtractor: (content) => content.match(/[A-Za-z0-9-_:/]+/g) || [],
})

// exports

module.exports = {
  client: {
    entry: config.client.entry(),
    output: config.client.output(),
    resolve: { alias, extensions, mainFields },
    module: {
      rules: [
        {
          test: /\.(svelte|html)$/,
          use: {
            loader: 'svelte-loader-hot',
            options: {
              dev,
              preprocess,
              hydratable: true,
              hotReload: true,
              emitCss: !dev,
              hotOptions: {
                noPreserveState: false, // Default: false
                optimistic: true, // Default: false
              },
            },
          },
        },
        {
          test: /\.s?css$/,
          use: [
            {
              loader: MiniCssExtractPlugin.loader,
              options: {
                hmr: dev,
                reloadAll: true,
              },
            },
            'css-loader',
            !dev && {
              loader: 'postcss-loader',
              options: {
                parsers: 'postcss',
                plugins: [autoprefixer, cssnano, purgecss],
              },
            },
            {
              loader: 'sass-loader',
              options: { sourceMap: false },
            },
          ].filter(Boolean),
        },
      ],
    },
    mode,
    plugins: [
      dev && new webpack.HotModuleReplacementPlugin(),
      new webpack.DefinePlugin({
        'process.browser': true,
        'process.env.NODE_ENV': JSON.stringify(mode),
      }),
      new MiniCssExtractPlugin({
        filename: '[hash]/[name].css',
        chunkFilename: '[hash]/[name].[id].css',
        ignoreOrder: true, // Enable to remove warnings about conflicting order
      }),
    ].filter(Boolean),
    devtool: dev && 'inline-source-map',
  },

  server: {
    entry: config.server.entry(),
    output: config.server.output(),
    target: 'node',
    resolve: { alias, extensions, mainFields },
    externals: Object.keys(pkg.dependencies).concat('encoding'),
    module: {
      rules: [
        {
          test: /\.(svelte|html)$/,
          use: {
            loader: 'svelte-loader-hot',
            options: {
              css: false,
              generate: 'ssr',
              dev,
              preprocess,
            },
          },
        },
      ],
    },
    mode: process.env.NODE_ENV,
    performance: {
      hints: false, // it doesn't matter if server.js is large
    },
  },

  serviceworker: {
    entry: config.serviceworker.entry(),
    output: config.serviceworker.output(),
    mode: process.env.NODE_ENV,
  },
}
