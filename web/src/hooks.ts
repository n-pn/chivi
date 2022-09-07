const api_host = 'localhost:5010'

export async function handle({ event, resolve }) {
  const path = event.url.pathname
  if (!path.match(/^\/api|_/)) return resolve(event)

  // if (!path.startsWith('/_')) return resolve(event)

  const base = path.split('/')[1]

  let host = api_host
  if (base == '_ys') host = 'localhost:5509'
  else if (base == '_v2') host = 'localhost:5502'

  const { method, headers: req_header, body } = event.request
  const headers = Object.fromEntries(req_header)
  delete headers.connection

  const url = `http://${host}${path}${event.url.search}`
  return await fetch(url, { body, method, headers })
}

export async function getSession({ request: { headers } }) {
  const cookie = headers.get('cookie')
  const url = `http://${api_host}/api/_self`
  const res = await fetch(url, { headers: { cookie } })
  return await res.json()
}
