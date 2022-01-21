export async function handle({ event, resolve }) {
  const path = event.url.pathname
  if (!path.startsWith('/api/')) return resolve(event)

  const api_url = `http://localhost:5010${path}${event.url.search}`
  return await fetch(new Request(api_url, event.request))
}

export async function getSession({ request: { headers } }) {
  const res = await fetch('http://localhost:5010/api/user/_self', { headers })
  if (res.ok) return await res.json()
  return { uname: 'Khách', privi: -1, wtheme: 'light' }
}
