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

  // console.log({ res_headers })
  return {
    status: res.status,
    headers: res_headers,
    body: await res.text(),
  }
}

const cached = {}

export async function getSession({ headers }) {
  const cookie = getCookie(headers.cookie || '', 'chivi_sc')
  if (!cookie) return { uname: 'Khách', privi: '-1' }

  cached[cookie] ||= await currentUser(headers)
  return cached[cookie]
}

function getCookie(cookies, cookie_name = 'svkit_ud') {
  for (const cookie of cookies.split(';')) {
    const [name, value] = cookie.split('=')
    if (name == cookie_name) return value.substr(0, 20)
  }
  return null
}

async function currentUser(headers) {
  const url = 'http://localhost:5010/api/_self'
  const res = await fetch(url, {
    headers: {
      'Content-Type': 'application/json',
      'cookie': headers.cookie,
    },
  })

  const data = await res.json()
  return data
}
