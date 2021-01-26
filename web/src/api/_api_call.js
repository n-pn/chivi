const storage = process.browser
  ? sessionStorage || localStorage
  : global.localStorage

function get_now(date = new Date()) {
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

export async function api_call(fetch, url, opts) {
  const now = get_now()
  const key = opts.key || url

  if (!opts.fresh) {
    const value = get_item(key, now)
    if (value) return value
  }

  const res = await fetch(`/api/${url}`)

  let state = res.ok ? 0 : res.status
  let value = res.ok ? await res.json() : await res.text()

  if (opts.ttl > 0) {
    set_item(key, state, value, now + opts.ttl * 60)
  }

  return [state, value]
}
