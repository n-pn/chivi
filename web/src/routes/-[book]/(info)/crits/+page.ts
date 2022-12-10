import { merge_search } from '$lib/api'
import { get_crits as get_yscrits } from '$lib/ys_api'
import { get_crits as get_vicrits } from '$lib/vi_api'

export async function load({ fetch, parent, url }) {
  const type = url.searchParams.get('type') || 'any'
  const sort = url.searchParams.get('sort') || 'score'

  const { nvinfo } = await parent()

  const opts = { book: nvinfo.id, take: 10, sort }
  const search = merge_search(url.searchParams, opts)

  return {
    ys: type == 'vi' ? {} : await get_yscrits(url.searchParams, opts, fetch),
    vi: type == 'ys' ? {} : await get_vicrits(search.toString(), fetch),
  }
}
