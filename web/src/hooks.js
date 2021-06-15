export async function handle({ request, resolve }) {
  if (request.path.startsWith('/api/')) {
    const { path, query } = request
    const url = `http://localhost:5010${path}?${query.toString()}`

    const res = await fetch(url, {
      method: request.method,
      headers: request.headers,
      body: request.rawBody,
    })

    return {
      status: res.status,
      headers: res.headers,
      body: await res.text(),
    }
  }

  return resolve(request)
}
