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

export const load = (async ({ fetch, url, parent }) => {
  const { dinfo } = await parent()

  const query = merge_query(url.searchParams, { d_id: dinfo.d_id, lm: 50 })
  const table = await api_get<TermsData>(`/_ai/zvdefns?${query}`, fetch)

  const _meta = {
    left_nav: [
      nav_link('/mt/dicts', 'Từ điển', 'package', { show: 'ts' }),
      nav_link(dinfo.name, dinfo.label, '', { kind: 'title' }),
    ],
  }

  const filter = gen_query(url.searchParams)
  const _title = 'Từ điển: ' + dinfo.label

  return { table, filter, _meta, _title }
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
