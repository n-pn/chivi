import sirv from 'sirv'
import polka from 'polka'
import compression from 'compression'
import * as sapper from '@sapper/server'
import { createProxyMiddleware } from 'http-proxy-middleware'

import MemoryStorage from './utils/memory_storage'
global.localStorage = new MemoryStorage()

const { PORT, NODE_ENV } = process.env
const dev = NODE_ENV === 'development'

const proxy = createProxyMiddleware('/api/', {
  target: 'http://localhost:5010',
  changeOrigin: true,
  pathRewrite: (path) => encodeURI(path),
})

const maxAge = 120 * 24 * 3600
const assetOpts = { dev, maxAge, etag: true }

const app = polka() // You can also use Express

app.use('api', proxy)
app.use('covers', sirv('../_db/nvdata/bcovers', assetOpts))

app.use(
  compression({ threshold: 0 }),
  sirv('static', assetOpts),
  sapper.middleware()
)

app.listen(PORT || 5000, '0.0.0.0', (err) => {
  if (err) console.log('error: ', err)
})
