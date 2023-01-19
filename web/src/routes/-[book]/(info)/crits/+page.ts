import { merge_query, api_path } from '$lib/api_call'
import type { PageLoad } from './$types'

export const load = (async ({ fetch, parent, url }) => {
  const sort = url.searchParams.get('sort') || 'score'
  const { nvinfo } = await parent()

  const extras = { book: nvinfo.id, lm: 10, sort }
  const search = merge_query(url.searchParams, extras)

  // prettier-ignore
  const empty = { crits: [], books: [], users: [], lists: [], pgmax: 0, pgidx: 0 }

  const from = url.searchParams.get('from') || 'any'
  const vi_path = api_path('vicrits.index', 0, search)
  const ys_path = api_path('yscrits.index', 0, search)

  return {
    ys: from == 'cv' ? empty : await fetch(ys_path).then((r) => r.json()),
    vi: from == 'ys' ? empty : await fetch(vi_path).then((r) => r.json()),
  }
}) satisfies PageLoad
