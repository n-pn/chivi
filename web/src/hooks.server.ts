export async function handle({ event, resolve }) {
  event.locals._user = await getSession(event)
  return await resolve(event, {
    filterSerializedResponseHeaders: (_: string) => true,
  })
}

const api_hosts = {
  _ys: 'localhost:5509',
  _mt: 'localhost:5502',
  api: 'localhost:5010',
}
export async function handleFetch({ request }) {
  const url = new URL(request.url)
  const path = url.pathname

  if (!path.match(/^\/api|_/)) return fetch(request)

  const host = api_hosts[path.split('/')[1]]
  if (host) url.host = host

  const { body, headers, method } = request
  return await globalThis.fetch(url, { body, headers, method })
}

export async function getSession({ request: { headers } }) {
  const cookie = headers.get('cookie')
  const url = `http://localhost:5010/api/_self`
  const res = await fetch(url, { headers: { cookie } })

  return await res.json()
}
