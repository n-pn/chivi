import sirv from 'sirv'
import polka from 'polka'
import compression from 'compression'
import * as sapper from '@sapper/server'

const { PORT, NODE_ENV } = process.env
const dev = NODE_ENV === 'development'

import { createProxyMiddleware } from 'http-proxy-middleware'

const proxy = createProxyMiddleware('/api', {
  target: 'http://localhost:5110',
  changeOrigin: true,
  pathRewrite: (path) => encodeURI(path),
})

polka() // You can also use Express
  .use(
    proxy,
    compression({ threshold: 0 }),
    sirv('static', { dev }),
    sirv('upload', { dev }),
    sapper.middleware()
  )
  .listen(PORT, '0.0.0.0', (err) => {
    if (err) console.log('error', err)
  })
