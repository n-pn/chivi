/// <reference lib="webworker" />

import { build, files, version } from '$service-worker'

const worker = self as unknown as ServiceWorkerGlobalScope
const FILES = `cache${version}`

// `build` is an array of all the files generated by the bundler,
// `files` is an array of everything in the `static` directory
const assetFiles = build.concat(files)
const staticAssets = new Set(assetFiles)

worker.addEventListener('install', (event) => {
  event.waitUntil(
    caches
      .open(FILES)
      .then((cache) => cache.addAll(assetFiles))
      .then(worker.skipWaiting)
  )
})

worker.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then(async (keys) => {
      // delete old caches
      for (const key of keys) if (key !== FILES) await caches.delete(key)
      worker.clients.claim()
    })
  )
})

/**
 * Fetch the asset from the network and store it in the cache.
 * Fall back to the cache if the user is offline.
 */
async function fetchAndCache(request: Request) {
  const cache = await caches.open(`offline${version}`)

  try {
    const response = await fetch(request)
    cache.put(request, response.clone())
    return response
  } catch (err) {
    const response = await cache.match(request)
    if (response) return response

    throw err
  }
}

worker.addEventListener('fetch', ({ request, respondWith }) => {
  if (request.method !== 'GET' || request.headers.has('range')) return
  const url = new URL(request.url)

  // don't try to handle e.g. data: URIs
  const isHttp = url.protocol.startsWith('http')
  const isDevServerRequest =
    url.hostname === self.location.hostname && url.port !== self.location.port
  const isStaticAsset =
    url.host === self.location.host && staticAssets.has(url.pathname)
  const skipBecauseUncached =
    request.cache === 'only-if-cached' && !isStaticAsset

  if (isHttp && !isDevServerRequest && !skipBecauseUncached) {
    respondWith(
      (async function () {
        if (isStaticAsset) {
          const cachedResponse = await caches.match(request)
          if (cachedResponse) return cachedResponse
        }
        return await fetchAndCache(request)
      })()
    )
  }
})
