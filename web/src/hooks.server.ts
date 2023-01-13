export async function handle({ event, resolve }) {
  event.locals._user = await getSession(event)

  return resolve(event, {
    filterSerializedResponseHeaders: (name: string) => {
      return name != 'location' && name != 'link'
    },
  })
}

const api_hosts = {
  _ys: 'localhost:5509',
  _mt: 'localhost:5502',
  _mh: 'localhost:5501',
  // _db: 'localhost:5010',
  api: 'localhost:5010',
}

export async function handleFetch({ event, fetch, request }) {
  const url = new URL(request.url)
  const host = api_hosts[url.pathname.split('/')[1]]
  if (!host) return fetch(request)

  url.protocol = 'http'
  url.host = host

  request = new Request(url, event.request)
  request.headers.delete('connection')

  return fetch(request)
}

export function handleError({ error, event }) {
  // console.log(event)
  console.log({ error })

  return {
    message: error.toString(),
    code: error.code ?? 'UNKNOWN',
  }
}

interface CachedUser {
  data: App.CurrentUser
  ttl: number
}

const cached_users: Record<string, CachedUser> = {}

async function getSession({ fetch, cookies, request: { headers } }) {
  const cookie = cookies.get('_sess')

  const now = new Date().getTime()

  let cached_user = cached_users[cookie]
  if (cached_user && cached_user.ttl >= now) return cached_user.data

  const url = `http://localhost:5010/api/_self`
  const res = await fetch(url, { headers: { cookie: headers.get('cookie') } })

  if (!res.ok) return { uname: 'Khách', privi: -2 }

  const user_data = await res.json()
  cached_users[cookie] = { data: user_data, ttl: now + 3 * 60000 }
  return user_data
}
