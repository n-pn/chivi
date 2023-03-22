import { merge_query, api_get } from '$lib/api_call'

const get = async <T>(
  path: string,
  fetch: CV.Fetch,
  search: URLSearchParams
) => {
  const url = `${path}?${search}`
  return await api_get<T>(url, fetch)
}

const empty_crits = {
  crits: [],
  books: [],
  users: [],
  lists: [],
  pgmax: 0,
  pgidx: 0,
  total: 0,
}

export const load_crits = async (url: URL, fetch: CV.Fetch, opts = {}) => {
  opts['sort'] ||= url.searchParams.get('sort') || 'score'
  opts['lm'] ||= 10

  const search = merge_query(url.searchParams, opts)

  const from = url.searchParams.get('from') || ''

  let vi: CV.VicritList = empty_crits
  if (from != 'ys') vi = await get<CV.VicritList>('/_db/crits', fetch, search)

  let ys: CV.YscritList = empty_crits
  if (from != 'vi') ys = await get<CV.YscritList>('/_ys/crits', fetch, search)

  return { vi, ys }
}

const empty_list_page = {
  lists: [],
  users: [],
  pgmax: 0,
  pgidx: 0,
  total: 0,
}

export const load_lists = async (url: URL, fetch: CV.Fetch, opts = {}) => {
  opts['sort'] ||= url.searchParams.get('sort') || 'score'
  opts['lm'] ||= 10

  const search = merge_query(url.searchParams, opts)

  const from = url.searchParams.get('from') || ''

  let vi: CV.VilistList = empty_list_page
  if (from != 'ys') vi = await get<CV.VilistList>('/_db/lists', fetch, search)

  let ys: CV.YslistList = empty_list_page
  if (from != 'vi') ys = await get<CV.YslistList>('/_ys/lists', fetch, search)

  return { vi, ys }
}
