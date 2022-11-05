export async function handle({ event, resolve }) {
  event.locals._user = await getSession(event)

  return resolve(event, {
    filterSerializedResponseHeaders: (_name: string) => true,
  })
}

const api_hosts = {
  _ys: 'localhost:5509',
  _mt: 'localhost:5502',
  _db: 'localhost:5010',
  api: 'localhost:5010',
}

export async function handleFetch({ fetch, request }) {
  const url = new URL(request.url)
  const host = api_hosts[url.pathname.split('/')[1]]

  if (host) {
    url.protocol = 'http'
    url.host = host
    request = new Request(url, request)
  }

  return fetch(request)
}

// export async function handleFetch({ event, fetch, request }) {
//   const url = new URL(request.url)
//   const host = api_hosts[url.pathname.split('/')[1]]
//   if (!host) return fetch(request)

//   url.protocol = 'http'
//   url.host = host

//   const { method, body, headers: req_headers } = event.request

//   const headers = Object.fromEntries(req_headers)
//   delete headers.connection
//   delete headers['accept-encoding']

//   return globalThis.fetch(url, { method, body, headers })
// }

export function handleError({ error, event }) {
  console.log(event)

  return {
    message: 'Whoops!',
    code: error.code ?? 'UNKNOWN',
  }
}
async function getSession({ request: { headers } }) {
  const cookie = headers.get('cookie')
  const url = `http://localhost:5010/api/_self`
  const res = await fetch(url, { headers: { cookie } })

  return await res.json()
}
