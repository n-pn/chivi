import { api_call, set_item } from './_api_call'

function nvmark_key(uname, bhash) {
  return `nvmark:${uname.toLowerCase()}-${bhash}`
}

export async function get_nvmark(fetch, uname, bhash, ttl = 1) {
  const key = nvmark_key(uname, bhash)
  return await api_call(fetch, `_self/nvmarks/${bhash}`, { key, ttl })
}

export async function set_nvmark(fetch, uname, bhash, nvmark, ttl = 5) {
  if (uname == 'Khách') return

  const url = `/api/book-marks/${bhash}?nvmark=${nvmark}`
  await fetch(url, { method: 'PUT' })

  set_item(nvmark_key(uname, bhash), 0, nvmark, ttl)
}
