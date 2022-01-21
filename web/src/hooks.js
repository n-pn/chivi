export async function handle({ event, resolve }) {
  if (event.url.pathname.startsWith('/api/')) return await mutateFetch(event)
  return resolve(event)
}

async function mutateFetch({ url, request }) {
  const api_url = 'http://localhost:5010' + request.url
  const res = await fetch(api_url, request)

  const res_headers = {}
  for (let [key, val] of res.headers.entries()) res_headers[key] = val
  const res_body = await res.text()

  const locals = {}
  if (res.ok && url.pathname.startsWith('/api/user')) {
    locals.user = JSON.parse(res_body)
  }
  return { status: res.status, headers: res_headers, body: res_body, locals }
}

const users = {}

export async function getSession({ request: { headers }, locals }) {
  const token = getUserToken(headers.cookie || '')
  users[token] = locals.user || users[token] || (await currentUser(headers))
  return users[token]
}

function getUserToken(cookies) {
  for (const cookie of cookies.split('; ')) {
    const [name, ...value] = cookie.split('=')
    if (name == 'chivi_sc') return value.join('=')
  }
  return '__guest__'
}

async function currentUser(headers) {
  const res = await fetch('http://localhost:5010/api/user/_self', { headers })
  if (res.ok) return await res.json()
  return { uname: 'Khách', privi: -1, wtheme: 'light', tlmode: 0 }
}
