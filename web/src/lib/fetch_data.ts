import { merge_query, api_get } from '$lib/api_call'
import type { URLSearchParams } from 'url'

const fetch_data = async <T>(
  path: string,
  search: URLSearchParams,
  fetch: CV.Fetch = globalThis.fetch
) => {
  const url = `${path}?${search}`
  return await api_get<T>(url, fetch)
}

const empty_crits = {
  crits: [],
  books: {},
  users: {},
  lists: {},
  memos: {},
  pgmax: 0,
  pgidx: 0,
  total: 0,
}

export const load_vi_crits = async (
  query = 'lm=10',
  fetch = globalThis.fetch
) => {
  try {
    return await api_get<CV.VicritList>(`/_db/crits?${query}`, fetch)
  } catch (ex) {
    return empty_crits as CV.VicritList
  }
}

export const load_ys_crits = async (
  query = 'lm=10',
  fetch = globalThis.fetch
) => {
  try {
    return await api_get<CV.YscritList>(`/_ys/crits?${query}`, fetch)
  } catch {
    return empty_crits as CV.YscritList
  }
}

export const load_crits = async (
  url: URL,
  opts = {},
  fetch: CV.Fetch = globalThis.fetch
) => {
  opts['sort'] ||= url.searchParams.get('sort') || 'score'
  opts['lm'] ||= 10

  const search = merge_query(url.searchParams, opts)
  const from = opts['from'] || url.searchParams.get('from') || ''

  let vi: CV.VicritList = empty_crits
  let ys: CV.YscritList = empty_crits

  if (from != 'ys') {
    vi = await fetch_data<CV.VicritList>('/_db/crits', search, fetch)
  }

  if (from == 'ys' || from == '') {
    ys = await fetch_data<CV.YscritList>('/_ys/crits', search, fetch)
  }

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
