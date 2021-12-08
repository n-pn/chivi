import { call_api } from './_api_call'

export async function dict_lookup(fetch, input, dname) {
  return await call_api(fetch, `dicts/${dname}/lookup`, { input })
}

export async function dict_search(fetch, words, dname = 'combine') {
  return await call_api(fetch, `dicts/${dname}/search`, { words })
}

export async function dict_upsert(fetch, dname, params) {
  return await call_api(fetch, `dicts/${dname}/upsert`, params)
}
