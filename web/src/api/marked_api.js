import { api_call, put_fetch } from './_api_call'

function mark_key(uname, bhash) {
  return `mark:${uname.toLowerCase()}-${bhash}`
}

export async function get_mark(fetch, uname, bhash, ttl = 1) {
  const key = mark_key(uname, bhash)
  return await api_call(fetch, `mark-books/${bhash}`, { key, ttl })
}

export async function set_mark(fetch, uname, bhash, bmark, ttl = 1) {
  if (uname == 'Khách') return

  const url = `/api/mark-books/${bhash}`
  await put_fetch(fetch, url, { bmark })
}
