import { api_call } from './_api_call'

export async function get_self(fetch, ttl = 10, cache = true, fresh = false) {
  return await api_call(fetch, `_self`, { key: `_self_`, ttl, fresh })
}
