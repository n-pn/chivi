export function get_now(date = new Date()) {
  return Math.round(date.getTime() / 1000)
}

export function get_item(key, now = get_now()) {
  if (!storage) return null

  const cached = storage.getItem(key)
  if (cached) {
    const value = JSON.parse(cached)
    if (value[2] >= now) return value
  }

  return null
}

export function set_item(key, state, value, ttl = get_now() + 60) {
  if (!storage) return null
  storage.setItem(key, JSON.stringify([state, value, ttl]))
}

export function remove_item(key) {
  storage.removeItem(key)
}

export async function api_call(fetch, url) {
  const res = await fetch(`/api/${url}`)

  let state = res.ok ? 0 : res.status
  let value = res.ok ? await res.json() : await res.text()

  return [state, value]
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
