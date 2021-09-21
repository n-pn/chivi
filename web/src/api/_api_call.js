export async function api_call(fetch, route) {
  const res = await fetch(`/api/${route}`, {
    headers: { 'Content-Type': 'application/json' },
  })

  if (res.ok) return [0, await res.json()]
  return [res.status, await res.text()]
}

export async function put_fetch(fetch, url, params) {
  const res = await fetch(url, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(params),
  })

  if (res.ok) return [0, await res.json()]
  return [res.status, await res.text()]
}
