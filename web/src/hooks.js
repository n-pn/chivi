export async function handle({ request, resolve }) {
  if (request.path.startsWith('/api/')) return await mutateFetch(request)
  return resolve(request)
}

/** @type {import('@sveltejs/kit').ServerFetch} */
export async function serverFetch(request) {
  // if (request.path.startsWith('/api/')) {
  //   const url = `http://localhost:5010${request.url}`
  //   console.log({ url })
  //   request = new Request(url, request)
  // }

  // return await fetch(request)
  return fetch(request)
}

async function mutateFetch({ path, query, method, headers, rawBody: body }) {
  const url = `http://localhost:5010${path}?${query.toString()}`
  const res = await fetch(url, { method, headers, body })

  const res_headers = {}
  for (let [key, val] of res.headers.entries()) res_headers[key] = val

  return {
    status: res.status,
    headers: res_headers,
    body: await res.text(),
  }
}

const cached = {}

export async function getSession({ headers }) {
  const cookie = getChiviSc(headers.cookie || '')
  if (!cookie) return { uname: 'Khách', privi: '-2' }

  cached[cookie] ||= await currentUser(headers)
  return cached[cookie]
}

function getChiviSc(cookies) {
  for (const cookie of cookies.split('; ')) {
    const [name, ...value] = cookie.split('=')
    if (name == 'chivi_sc') return value.join('=')
  }
  return null
}

async function currentUser(headers) {
  const url = 'http://localhost:5010/api/_self'
  const res = await fetch(url, { headers })

  const data = await res.json()
  return data
}
