const api_host = '127.0.0.1:5010'

export async function handle({ event, resolve }) {
  const path = event.url.pathname
  if (!path.startsWith('/api/')) return resolve(event)

  event.url.host = api_host
  return await fetch(new Request(event.url, event.request))
}

export async function getSession({ request: { headers } }) {
  const res = await fetch(`http://${api_host}/api/_self`, { headers })
  return await res.json()
}
