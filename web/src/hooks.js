const users = {}

export async function handle({ event, resolve }) {
  const path = event.url.pathname
  if (path.startsWith('/api/')) {
    const api_url = `http://localhost:5010${path}${event.url.search}`
    const response = await fetch(new Request(api_url, event.request))

    if (response.ok && path.startsWith('/api/user')) {
      const user_token = getUserToken(response.headers.cookie || '')
      users[user_token] = null
    }

    return response
  }

  return resolve(event)
}

// export async function externalFetch(request) {
//   console.log(request.url)

//   if (request.url.startsWith('http://localhost:3000/api/')) {
//     // clone the original request, but change the URL
//   }

//   return fetch(request)
// }

export async function getSession({ request: { headers } }) {
  const token = getUserToken(headers.cookie || '')
  users[token] = users[token] || (await currentUser(headers))
  return users[token]
}

function getUserToken(cookies) {
  for (const cookie of cookies.split('; ')) {
    if (!cookie) continue
    const [name, ...value] = cookie.split('=')
    if (name == 'chivi_sc') return value.join('=')
  }
  return '__guest__'
}

async function currentUser(headers) {
  const res = await fetch('http://localhost:5010/api/user/_self', { headers })
  if (res.ok) return await res.json()
  return { uname: 'Khách', privi: -1, wtheme: 'light' }
}
