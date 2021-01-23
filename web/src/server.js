import sirv from 'sirv'
import polka from 'polka'
import compression from 'compression'
import * as sapper from '@sapper/server'

const { PORT, NODE_ENV } = process.env
const dev = NODE_ENV === 'development'

import { createProxyMiddleware } from 'http-proxy-middleware'

const proxy = createProxyMiddleware('/api/', {
  target: 'http://localhost:5010',
  changeOrigin: true,
  pathRewrite: (path) => encodeURI(path),
})

const maxAge = 3 * 30 * 24 * 3600
const assetOpts = { dev, maxAge, etag: true }

const app = polka() // You can also use Express
  app.use(
    proxy,
    compression({ threshold: 0 }),
    sirv('static', assetOpts),
    sirv('public', assetOpts),
    sapper.middleware()
  )
}

app.listen(PORT || 5000, '0.0.0.0', (err) => {
  if (err) console.log('error: ', err)
})
