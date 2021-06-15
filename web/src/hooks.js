export async function handle({ request, resolve }) {
  if (request.path.startsWith('/api/')) return await serverFetch(request)
  return resolve(request)
}

async function serverFetch({ path, query, method, headers, rawBody: body }) {
  const url = `http://localhost:5010${path}?${query.toString()}`
  const res = await fetch(url, { method, headers, body })

  return {
    status: res.status,
    headers: res.headers,
    body: await res.text(),
  }
}
