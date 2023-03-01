import { merge_query, api_path, api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

const empty_list = {
  crits: [],
  books: [],
  users: [],
  lists: [],
  pgmax: 0,
  pgidx: 0,
  total: 0,
}

export const load = (async ({ fetch, params, url }) => {
  const sort = url.searchParams.get('sort') || 'score'
  const extras = { book: params.wn_id, lm: 10, sort }
  const search = merge_query(url.searchParams, extras)

  const from = url.searchParams.get('from') || ''

  const ys: CV.YscritList = empty_list
  const vi: CV.VicritList = empty_list

  return {
    ys: from == 'cv' ? ys : await load_ys_crits(fetch, search),
    vi: from == 'ys' ? vi : await load_vi_crits(fetch, search),
  }
}) satisfies PageLoad

const load_vi_crits = async (fetch: CV.Fetch, search: URLSearchParams) => {
  const url = api_path('/_db/crits', 0, search)
  return await api_get<CV.VicritList>(url, fetch)
}

const load_ys_crits = async (fetch: CV.Fetch, search: URLSearchParams) => {
  const url = api_path('yscrits.index', 0, search)
  return await api_get<CV.YscritList>(url, fetch)
}
