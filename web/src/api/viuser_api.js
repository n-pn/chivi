import { api_call, set_item, remove_item, get_now } from './_api_call'

export async function get_self(fetch, ttl = 10, fresh = false) {
  return await api_call(fetch, `_self`, { key: `_self_`, ttl, fresh })
}

export async function signin_user(fetch, type, params, ttl = 10) {
  const res = await fetch(`/api/${type}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(params),
  })

  if (!res.ok) return [res.status, await res.text()]

  const value = await res.json()
  set_item('_self_', 0, value, get_now() + 60 * ttl)
  return [0, value]
}

export async function logout_user(fetch) {
  await fetch('/api/logout')
  remove_item('_self_')
}
