const api_host = 'localhost:5010'

export async function handle({ event, resolve }) {
  const path = event.url.pathname
  if (!path.startsWith('/api/')) return resolve(event)

  const api_url = `http://${api_host}${path}${event.url.search}`
  return await fetch(new Request(api_url, event.request))
}

export async function getSession({ request: { headers } }) {
  const res = await fetch(`http://${api_host}/api/_self`, { headers })
  return await res.json()
}
