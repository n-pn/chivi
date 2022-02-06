export async function api_call(fetch, route) {
  const res = await fetch(`/api/${route}`, {
    headers: { 'Content-Type': 'application/json' },
  })

  const data = await res.json()
  if (res.ok) return [0, data.props, data.maxage]
  return [res.status, data.error]
}

export async function call_api(fetch, url, body, method = 'PUT') {
  const opts = {
    headers: { 'Content-Type': 'application/json' },
    method,
  }
  if (body) opts.body = JSON.stringify(body)

  const res = await fetch('/api/' + url, opts)
  const data = await res.json()
  if (res.ok) return [0, data.props, data.maxage]
  return [res.status, data.error]
}
