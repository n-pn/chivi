import { put_fetch } from './_api_call'

export async function dict_lookup(fetch, input, dname) {
  const url = `/api/dicts/${dname}/lookup`
  return await put_fetch(fetch, url, { input })
}

export async function dict_search(fetch, input, dname = 'combine') {
  const url = `/api/dicts/${dname}/search`
  return await put_fetch(fetch, url, { input })
}

export async function dict_upsert(fetch, dname, params) {
  const url = `/api/dicts/${dname}/upsert`
  return await put_fetch(fetch, url, params)
}
