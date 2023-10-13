/// <reference types="@sveltejs/kit" />
/// <reference no-default-lib="true"/>
/// <reference lib="esnext" />
/// <reference lib="webworker" />

import { build, files, version } from '$service-worker'

const worker = self as unknown as ServiceWorkerGlobalScope
const CACHE = `cv-cache-${version}`

// `build` is an array of all the files generated by the bundler,
// `files` is an array of everything in the `static` directory
const ASSET_ARR = build.concat(files)
const ASSET_SET = new Set(ASSET_ARR)

worker.addEventListener('install', (event) => {
  async function addFilesToCache() {
    const cache = await caches.open(CACHE)
    await cache.addAll(ASSET_ARR)
    // await worker.skipWaiting()
  }
  event.waitUntil(addFilesToCache())
})

worker.addEventListener('activate', (event) => {
  async function deleteOldCaches() {
    for (const key of await caches.keys()) {
      if (key !== CACHE) await caches.delete(key)
    }
    // await worker.clients.claim()
  }

  event.waitUntil(deleteOldCaches())
})

worker.addEventListener('fetch', (event) => {
  if (event.request.method !== 'GET') return
  if (event.request.headers.has('range')) return

  async function respond() {
    const url = new URL(event.request.url)
    const cache = await caches.open(CACHE)

    // `build`/`files` can always be served from the cache
    if (ASSET_SET.has(url.pathname)) {
      const response = await cache.match(url.pathname)
      if (response) return response
    }

    // for everything else, try the network first, but
    // fall back to the cache if we're offline
    try {
      const response = await fetch(event.request)

      if (response.status < 300 && event.request.cache != 'only-if-cached') {
        cache.put(event.request, response.clone())
      }

      return response
    } catch (ex) {
      const response = await cache.match(event.request)
      if (response) return response

      return new Response('Có lỗi tải tài nguyên. Thử tắt trang và mở lại.', {
        status: 408,
        headers: { 'Content-Type': 'text/html' },
      })
    }
  }

  event.respondWith(respond())
})

worker.addEventListener('push', function (event) {
  try {
    const payload = event.data
      ? event.data.json()
      : { title: 'Chivi', body: 'Có thông báo mới từ Chivi!' }

    if (payload) {
      const { title, ...options } = payload
      event.waitUntil(worker.registration.showNotification(title, options))
    } else {
      console.warn('No payload for push event', event)
    }

    // TODO: We can also implement analytics for received pushes as well if we want:
    // https://web.dev/push-notifications-handling-messages/#wait-until
  } catch (e) {
    console.warn('Malformed notification', e)
  }
})

worker.addEventListener('notificationclick', (event: any) => {
  const clickedNotification = event?.notification
  clickedNotification.close()

  event.waitUntil(
    worker.clients
      .matchAll({ type: 'window' })
      .then((clients) => {
        if (clients.length && clients.length > 0) {
          const client = clients[0]
          if (!client.url.includes('/me/notif')) client.navigate('/me/notif')
          client.focus()
        } else
          worker.clients
            .openWindow('/me/notif')
            .then((window) => (window ? window.focus() : null))
      })
      .catch((e) => {
        console.error(e)
      })
  )
})
