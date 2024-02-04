import { merge_query, api_get } from '$lib/api_call'

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

export const load_vi_crits = async (query = 'lm=10', fetch = globalThis.fetch) => {
  try {
    return await api_get<CV.VicritList>(`/_db/crits${query}`, fetch)
  } catch (ex) {
    return empty_crits as CV.VicritList
  }
}

export const load_ys_crits = async (query = 'lm=10', fetch = globalThis.fetch) => {
  try {
    return await api_get<CV.YscritList>(`/_ys/crits${query}`, fetch)
  } catch {
    return empty_crits as CV.YscritList
  }
}

export const load_crits = async (scope = 'mixed', query = 'lm=10', fetch = globalThis.fetch) => {
  let vdata: CV.VicritList = empty_crits
  let ydata: CV.YscritList = empty_crits

  if (scope != 'ysapp') vdata = await load_vi_crits(query, fetch)
  if (scope != 'chivi') ydata = await load_ys_crits(query, fetch)

  return { vdata, ydata }
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

  const query = merge_query(url.searchParams, opts)

  const from = url.searchParams.get('from') || ''

  let vi: CV.VilistList = empty_list_page
  if (from != 'ys') {
    const url = `/_db/lists?${query}`

    vi = await api_get<CV.VilistList>(url, fetch)
  }

  let ys: CV.YslistList = empty_list_page
  if (from != 'vi') {
    const url = `/_ys/lists?${query}`

    ys = await api_get<CV.YslistList>(url, fetch)
  }

  return { vi, ys }
}
