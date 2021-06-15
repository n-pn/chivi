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
