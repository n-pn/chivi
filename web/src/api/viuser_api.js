import { api_call } from './_api_call.js'

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
  return [0, await res.json()]
}

export async function logout_user(fetch) {
  await fetch('/api/logout')
}
