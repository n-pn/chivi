const webpack = require('webpack')
const WebpackModules = require('webpack-modules')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')

const path = require('path')
const pkg = require('./package.json')
const config = require('sapper/config/webpack.js')

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

const purgecss = require('@fullhuman/postcss-purgecss')({
  content: ['./src/**/*.html', './src/**/*.svelte'],
  keyframes: true,
  whitelistPatterns: [/svelte-/],
  defaultExtractor: (content) => content.match(/[A-Za-z0-9-_:/]+/g) || [],
})

const loader_dev = {
  loader: 'svelte-loader-hot',
  options: {
    dev,
    preprocess,
    hydratable: true,
    hotReload: dev,
    emitCss: false,
  },
}

// const loader_prod = {
//   loader: 'svelte-loader',
//   options: {
//     dev,
//     preprocess,
//     hydratable: true,
//     hotReload: false,
//     emitCss: false,
//   },
// }

const svelte_loader = loader_dev

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
          use: svelte_loader,
        },
        {
          test: /\.s?css$/,
          use: [
            MiniCssExtractPlugin.loader,
            'css-loader',
            !dev && {
              loader: 'postcss-loader',
              options: {
                postcssOptions: {
                  parsers: 'postcss',
                  plugins: ['autoprefixer', 'cssnano', purgecss],
                },
              },
            },
            {
              loader: 'sass-loader',
              options: {
                sourceMap: dev,
                sassOptions: {
                  includePaths: [path.resolve(__dirname, 'src/styles')],
                },
              },
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
    plugins: [new WebpackModules()],
    performance: { hints: false },
  },

  serviceworker: {
    entry: config.serviceworker.entry(),
    output: config.serviceworker.output(),
    mode: process.env.NODE_ENV,
  },
}
