import Appnav from '$gui/global/Modals/Appnav.svelte'
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
  _ys: 'localhost:5509',
  _mt: 'localhost:5502',
  _mh: 'localhost:5501',
  // _db: 'localhost:5010',
  api: 'localhost:5010',
}

export const handleFetch = (async ({ event, fetch, request }) => {
  const url = new URL(request.url)
  const host = api_hosts[url.pathname.split('/')[1]]
  if (!host) return fetch(request)

  url.protocol = 'http'
  url.host = host

  request = new Request(url, event.request)
  request.headers.delete('connection')

  return fetch(request)
}) satisfies HandleFetch

export const handleError = (({ error }) => {
  // console.log(event)
  console.log({ error })
  return { message: error.toString(), code: 'UNKNOWN' }
}) satisfies HandleServerError

import * as fs from 'fs'
fs.mkdirSync('tmp/_user', { recursive: true })

const cached_users: Record<string, App.CurrentUser> = {}
const session_url = `http://localhost:5010/api/_self`
const guest_user = { uname: 'Khách', privi: -1, until: 0, vcoin: 0, karma: 0 }

const get_hash = (hash?: string) => hash?.substring(0, 12).replace('/', '_')

async function getSession(event: RequestEvent): Promise<App.CurrentUser> {
  const hash = get_hash(event.cookies.get('_auth')) || 'guest'
  let cached_user = cached_users[hash]

  const path = `tmp/_user/${hash}.json`

  if (!cached_user && fs.existsSync(path)) {
    const file_data = fs.readFileSync(path).toString()
    cached_user = JSON.parse(file_data) as App.CurrentUser
    cached_users[hash] = cached_user
  }

  const now_unix = new Date().getTime() / 1000
  if (cached_user && cached_user.until >= now_unix) return cached_user

  const req_init = { headers: { cookie: event.request.headers.get('cookie') } }
  const response = await event.fetch(session_url, req_init)

  if (!response.ok) return guest_user

  cached_user = (await response.json()) as App.CurrentUser
  fs.writeFileSync(path, JSON.stringify(cached_user))
  cached_users[hash] = cached_user

  event.setHeaders({ cookie: response.headers.get('cookie') })
  return cached_user
}
