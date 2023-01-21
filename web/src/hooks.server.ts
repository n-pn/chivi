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
  _db: '127.0.0.1:5010',
  _wn: '127.0.0.1:5020',

  _m0: '127.0.0.1:5100',
  _m1: '127.0.0.1:5110',
  _m2: '127.0.0.1:5120',

  _sp: '127.0.0.1:5300',
  _ys: '127.0.0.1:5400',
}

export const handleFetch = (({ event, request, fetch }) => {
  const url = new URL(request.url)
  const host = api_hosts[url.pathname.split('/')[1]]

  if (!host) return fetch(request)

  url.host = host
  url.protocol = 'http'

  // request.headers.delete('connection')
  // return fetch(new Request(url, request))
  const { method, headers, body } = request

  headers.set('cookie', event.request.headers.get('cookie'))
  headers.delete('connection')

  return globalThis.fetch(url, { method, headers, body })
}) satisfies HandleFetch

export const handleError = (({ event, error }) => {
  console.log({ event, error })
  return { message: error.toString(), code: 'UNKNOWN' }
}) satisfies HandleServerError

// import * as fs from 'fs'
// fs.mkdirSync('tmp/_user', { recursive: true })

const cached_users: Record<string, App.CurrentUser> = {}
const session_url = `http://127.0.0.1:5010/_db/_self`
const guest_user = { uname: 'Khách', privi: -1, until: 0, vcoin: 0, karma: 0 }

const get_hash = (hash?: string) => hash?.substring(0, 12).replace('/', '_')

async function getSession(event: RequestEvent): Promise<App.CurrentUser> {
  const hash = get_hash(event.cookies.get('_auth')) || 'guest'
  const path = `tmp/_user/${hash}.json`

  let cached_user = cached_users[hash]

  // if (!cached_user && fs.existsSync(path)) {
  //   const file_data = fs.readFileSync(path).toString()
  //   cached_user = JSON.parse(file_data) as App.CurrentUser
  //   cached_users[hash] = cached_user
  // }

  const now_unix = new Date().getTime() / 1000
  if (cached_user && cached_user.until >= now_unix) return cached_user

  const req_init = { headers: { cookie: event.request.headers.get('cookie') } }
  const response = await globalThis.fetch(session_url, req_init)

  if (!response.ok) return guest_user

  cached_user = (await response.json()) as App.CurrentUser
  fs.writeFileSync(path, JSON.stringify(cached_user))
  cached_users[hash] = cached_user

  event.setHeaders({ cookie: response.headers.get('cookie') })
  return cached_user || guest_user
}
