// import { api_call } from './_api_call'

async function fetch_api(fetch, url, params) {
  const res = await fetch(url, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(params),
  })
  return await res.json()
}

export async function dict_lookup(fetch, input, dname) {
  const url = `/api/dicts/${dname}/lookup`
  return await fetch_api(fetch, url, { input })
}

export async function dict_search(fetch, input, dname = 'various') {
  const url = `/api/dicts/${dname}/search`
  return await fetch_api(fetch, url, { input })
}

export async function dict_upsert(fetch, dname, params) {
  const url = `/api/dicts/${dname}/upsert`
  return await fetch_api(fetch, url, params)
}
