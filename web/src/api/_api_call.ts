export async function api_call(fetch, route: string) {
  const res = await fetch(`/api/${route}`, {
    headers: { 'Content-Type': 'application/json' },
  })

  const data = await res.json()
  if (res.ok) return [0, data.props, data.maxage]
  return [res.status, data.error]
}

export async function call_api(fetch, url: String, body: any, method = 'PUT') {
  const opts = {
    method,
    headers: { 'Content-Type': 'application/json' },
    body: body ? JSON.stringify(body) : null,
  }

  const res = await fetch('/api/' + url, opts)
  const data = await res.json()
  if (res.ok) return [0, data.props, data.maxage]
  return [res.status, data.error]
}
