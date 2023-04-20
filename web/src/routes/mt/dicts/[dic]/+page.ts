import { merge_query, api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

// FIXME: add type for term
export interface TermsData extends CV.Paginate {
  start: number
  terms: any[]
}

export interface V1Dict {
  vd_id: number
  dname: string

  label: string
  brief: string

  dsize: number
  users: string[]
}

export const load = (async ({ fetch, url, params: { dic } }) => {
  const dinfo = await api_get<V1Dict>(`/_m1/dicts/${dic}`, fetch)

  const search = merge_query(url.searchParams, { dic, lm: 50 })
  const terms = await api_get<TermsData>(`/_m1/defns?${search}`, fetch)

  const _meta = {
    title: 'Từ điển: ' + dinfo.label,
    left_nav: [
      home_nav('ps'),
      nav_link('/mt/dicts', 'Từ điển', 'package', { show: 'ts' }),
      nav_link(dic, dinfo.label, '', { kind: 'title' }),
    ],
  }

  const query = gen_query(url.searchParams)
  return { ...dinfo, ...terms, query, _meta }
}) satisfies PageLoad

function gen_query(params: URLSearchParams) {
  return {
    key: params.get('key') || '',
    val: params.get('val') || '',
    ptag: params.get('ptag') || '',
    prio: params.get('prio') || '',
    tab: params.get('tab') || '',
    uname: params.get('uname') || '',
  }
}
