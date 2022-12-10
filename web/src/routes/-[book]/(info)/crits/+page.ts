import { merge_search } from '$lib/api'
import { get_crits as get_yscrits } from '$lib/ys_api'
import { get_crits as get_vicrits } from '$lib/vi_api'

export async function load({ fetch, parent, url }) {
  const from = url.searchParams.get('from') || 'any'
  const sort = url.searchParams.get('sort') || 'score'

  const { nvinfo } = await parent()

  const opts = { book: nvinfo.id, take: 10, sort }
  const search = merge_search(url.searchParams, opts)

  // prettier-ignore
  const empty = { crits: [], books: [], users: [], lists: [], pgmax: 0, pgidx: 0 }

  return {
    ys: from == 'cv' ? empty : await get_yscrits(url.searchParams, opts, fetch),
    vi: from == 'ys' ? empty : await get_vicrits(search.toString(), fetch),
  }
}
