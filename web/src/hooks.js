export async function handle({ request, resolve }) {
  if (request.path.startsWith('/api/')) return await serverFetch(request)
  return resolve(request)
}

async function serverFetch({ path, query, method, headers, rawBody: body }) {
  const url = `http://localhost:5010${path}?${query.toString()}`
  const res = await fetch(url, { method, headers, body })

  const res_headers = {}

  for (let [key, val] of res.headers.entries()) {
    res_headers[key] = val
  }

  return {
    status: res.status,
    headers: res_headers,
    body: await res.text(),
  }
}

const sessions = {}

export async function getSession({ headers }) {
  const cookie = getCookie(headers.cookie || '', 'chivi_sc')
  if (!cookie) return { uname: 'Khách', privi: '-1' }

  sessions[cookie] ||= await currentUser(headers)
  return sessions[cookie]
}

function getCookie(cookies, name = 'chivi_sc') {
  for (const cookie of cookies.split(';')) {
    const parts = cookie.split('=')
    if (parts[0] == name) return parts[1]
  }
  return null
}

async function currentUser(headers) {
  const url = 'http://localhost:5010/api/_self'
  const res = await fetch(url, { headers })
  return await res.json()
}
