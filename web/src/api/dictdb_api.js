// import { api_call } from './_api_call'

export async function dict_search(fetch, key, dname = 'various') {
  const url = `/api/dictdb/search/${key}?dname=${dname}`
  const res = await fetch(url)
  return await res.json()
}

export async function dict_upsert(fetch, dname, params) {
  const url = `/api/dictdb/upsert/${dname}`
  const res = await fetch(url, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(params),
  })

  return res
}

export async function dict_lookup(fetch, input, dname) {
  const url = `/api/dictdb/lookup/${input}?dname=${dname}`
  const res = await fetch(url)
  return await res.json()
}
