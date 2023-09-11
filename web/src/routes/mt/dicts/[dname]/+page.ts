import { merge_query, api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export interface DictData {
  dinfo: CV.Vidict
  users: string[]
  // terms: CV.Viterm[]
}

// FIXME: add type for term
export interface TermsData extends CV.Paginate {
  items: CV.Viterm[]
  start: number
}

export const load = (async ({ fetch, url, params: { dname } }) => {
  const { dinfo, users } = await api_get<DictData>(`/_ai/dicts/${dname}`, fetch)

  const search = merge_query(url.searchParams, { dname, lm: 50 })
  const terms = await api_get<TermsData>(`/_ai/terms?${search}`, fetch)

  const _meta = {
    left_nav: [
      home_nav('ps'),
      nav_link('/mt/dicts', 'Từ điển', 'package', { show: 'ts' }),
      nav_link(dinfo.dname, dinfo.label, '', { kind: 'title' }),
    ],
  }

  const query = gen_query(url.searchParams)
  const _title = 'Từ điển: ' + dinfo.label

  return { dinfo, users, terms, query, _meta, _title }
}) satisfies PageLoad

function gen_query(params: URLSearchParams) {
  return {
    zstr: params.get('zstr') || '',
    vstr: params.get('vstr') || '',
    cpos: params.get('cpos') || '',
    attr: params.get('attr') || '',
    uname: params.get('uname') || '',
    _lock: params.get('_lock') || '',
  }
}
