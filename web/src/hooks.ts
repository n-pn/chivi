const api_host = 'localhost:5010'

export async function handle({ event, resolve }) {
  const path = event.url.pathname
  if (!path.match(/^\/api|_v2/)) return resolve(event)

  let api_host = 'localhost:5010'
  if (path.startsWith('/_v2')) api_host = 'localhost:5502'

  const api_url = `http://${api_host}${path}${event.url.search}`
  return await fetch(new Request(api_url, event.request))
}

export async function getSession({ request: { headers } }) {
  const res = await fetch(`http://${api_host}/api/_self`, { headers })
  return await res.json()
}
