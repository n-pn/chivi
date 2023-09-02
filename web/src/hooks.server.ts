import type {
  Handle,
  HandleFetch,
  HandleServerError,
  RequestEvent,
} from '@sveltejs/kit'

export const handle = (async ({ event, resolve }) => {
  event.locals._user = await getSession(event)

  return resolve(event, {
    filterSerializedResponseHeaders: (name: string) =>
      name != 'location' && name != 'link',
  })
}) satisfies Handle

const api_hosts = {
  _db: `127.0.0.1:${import.meta.env.VITE_BE_PORT || 5010}`,
  _wn: `127.0.0.1:${import.meta.env.VITE_WN_PORT || 5020}`,

  _m1: `127.0.0.1:${import.meta.env.VITE_M1_PORT || 5110}`,
  _ai: `127.0.0.1:${import.meta.env.VITE_AI_PORT || 5120}`,

  _sp: `127.0.0.1:${import.meta.env.VITE_SP_PORT || 5300}`,
  _ys: `127.0.0.1:${import.meta.env.VITE_YS_PORT || 5400}`,
}

export const handleFetch = (({ event, request, fetch }) => {
  const url = new URL(request.url)

  const head = url.pathname.split('/')[1]
  const host = api_hosts[head]

  if (!host) return fetch(request)

  url.host = host
  url.protocol = 'http'

  // request.headers.delete('connection')
  // return fetch(new Request(url, request))
  const { method, headers, body } = request

  headers.set('cookie', event.request.headers.get('cookie'))
  headers.delete('connection')

  return fetch(url, { method, headers, body })
}) satisfies HandleFetch

export const handleError = (({ event, error }) => {
  console.log({ error })
  return { message: error.toString(), code: 'UNKNOWN' }
}) satisfies HandleServerError

// import * as fs from 'fs'
// fs.mkdirSync('tmp/_user', { recursive: true })

type CachedUser = { user: App.CurrentUser; expiry: number }

const cached_users: Record<string, CachedUser> = {}
const session_url = `http://${api_hosts._db}/_db/_self`

const get_hash = (cookie: string) => cookie && cookie.replace('/', '_')

async function getSession(event: RequestEvent): Promise<App.CurrentUser> {
  const hash = get_hash(event.cookies.get('_a')) || 'guest'
  let cached_user = cached_users[hash]

  const now_unix = new Date().getTime() / 1000
  if (cached_user && cached_user.expiry >= now_unix) {
    return cached_user.user
  }

  const req_init = { headers: { cookie: event.request.headers.get('cookie') } }
  const response = await globalThis.fetch(session_url, req_init)

  if (!response.ok && cached_user) return cached_user.user

  const user = (await response.json()) as App.CurrentUser
  cached_users[hash] = { user, expiry: now_unix + 10 }

  return user
}
