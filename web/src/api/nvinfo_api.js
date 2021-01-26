import { api_call } from './_api_call'

export async function get_nvinfo(fetch, bslug, ttl = 5, fresh = false) {
  const opts = { key: `nvinfo:${bslug}`, ttl, fresh }
  return await api_call(fetch, `nvinfos/${bslug}`, opts)
}
