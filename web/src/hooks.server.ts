export async function handle({ event, resolve }) {
  event.locals._user = await getSession(event)

  return resolve(event, {
    filterSerializedResponseHeaders: (_name: string) => true,
  })
}

const api_hosts = {
  _ys: 'localhost:5509',
  _mt: 'localhost:5502',
  _tl: 'localhost:5501',
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
  console.log(error)

  return {
    message: error.toString(),
    code: error.code ?? 'UNKNOWN',
  }
}
async function getSession({ request: { headers } }) {
  const cookie = headers.get('cookie')
  const url = `http://localhost:5010/api/_self`
  const res = await fetch(url, { headers: { cookie } })

  return await res.json()
}
