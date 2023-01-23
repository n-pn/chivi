import { merge_query, api_path } from '$lib/api_call'
import { error } from '@sveltejs/kit'
import type { PageLoad } from './$types'

export const load = (async ({ fetch, params: { wn_id }, url }) => {
  const sort = url.searchParams.get('sort') || 'score'

  const extras = { book: wn_id, lm: 10, sort }
  const search = merge_query(url.searchParams, extras)

  // prettier-ignore
  const empty = { crits: [], books: [], users: [], lists: [], pgmax: 0, pgidx: 0 }

  const from = url.searchParams.get('from') || ''

  console.log(search)
  return {
    ys: from == 'cv' ? empty : await load_crits(fetch, search, 'yscrits.index'),
    vi: from == 'ys' ? empty : await load_crits(fetch, search, 'vicrits.index'),
  }
}) satisfies PageLoad

// prettier-ignore
const load_crits = async (fetch: CV.Fetch, search: URLSearchParams, type : string) => {
  const url = api_path(type, 0, search)
  const res = await fetch(url)
  if (res.ok) return await res.json()

  throw error(res.status, await res.text())
}
