const api_host = 'localhost:5010'

export async function handle({ event, resolve }) {
  const path = event.url.pathname
  if (!path.match(/^\/api|_v2/)) return resolve(event)

  let api_host = 'localhost:5010'
  if (path.startsWith('/_v2')) api_host = 'localhost:5502'

  const { method, headers: req_headers, body } = event.request
  const headers = Object.fromEntries(req_headers)
  delete headers.connection

  const url = `http://${api_host}${path}${event.url.search}`
  return await fetch(url, { body, method, headers })
}

export async function getSession({ request: { headers } }) {
  const cookie = headers.get('cookie')
  const url = `http://${api_host}/api/_self`
  const res = await fetch(url, { headers: { cookie } })
  return await res.json()
}
