import { nav_link } from '$utils/header_util'
import { merge_query, api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

export interface DictData {
  dinfo: CV.Zvdict
  users: string[]
  // terms: CV.Viterm[]
}

// FIXME: add type for term
export interface TermsData extends CV.Paginate {
  items: CV.Viterm[]
  start: number
}

export const load = (async ({ fetch, url, params: { dname }, parent }) => {
  const { dinfo } = await parent()
  dname = dname.replace(/^wn/, 'wn/').replace(/^up/, 'up/')

  const search = merge_query(url.searchParams, { dname, lm: 50 })
  const terms = await api_get<TermsData>(`/_ai/terms?${search}`, fetch)

  const _meta = {
    left_nav: [
      nav_link('/mt/dicts', 'Từ điển', 'package', { show: 'ts' }),
      nav_link(dinfo.name, dinfo.label, '', { kind: 'title' }),
    ],
  }

  const query = gen_query(url.searchParams)
  const _title = 'Từ điển: ' + dinfo.label

  return { terms, query, _meta, _title }
}) satisfies PageLoad

function gen_query(params: URLSearchParams) {
  return {
    zstr: params.get('zstr') || '',
    vstr: params.get('vstr') || '',
    cpos: params.get('cpos') || '',
    attr: params.get('attr') || '',
    uname: params.get('uname') || '',
    plock: params.get('plock') || '',
  }
}
