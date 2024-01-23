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
  _up: `127.0.0.1:${import.meta.env.VITE_UP_PORT || 5030}`,

  _rd: `127.0.0.1:${import.meta.env.VITE_RD_PORT || 5200}`,

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

  const { method, headers, body } = request

  headers.set('cookie', event.request.headers.get('cookie'))
  headers.delete('connection')

  return fetch(url, { method, headers, body })
}) satisfies HandleFetch

export const handleError = (({ event, error }) => {
  console.log({ error })
  return { message: error.toString(), code: 'UNKNOWN' }
}) satisfies HandleServerError

const session_url = `http://${api_hosts._db}/_db/_self`

const cached_users = new Map<string, App.CurrentUser>()

async function getSession(event: RequestEvent): Promise<App.CurrentUser> {
  const cookie = event.request.headers.get('cookie')
  const cached_user = cached_users.get(cookie)

  if (cached_user && cached_user.until > new Date().getTime() / 1000) {
    return cached_user
  }

  const req_init = { headers: { cookie } }
  const response = await globalThis.fetch(session_url, req_init)

  const user = (await response.json()) as App.CurrentUser
  const max_until = Math.floor(new Date().getTime() / 1000) + 1800
  if (!user.until || user.until > max_until) user.until = max_until

  cached_users.set(cookie, user)
  return user
}
