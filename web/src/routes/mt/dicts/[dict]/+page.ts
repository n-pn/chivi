import { api_path, api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$gui/global/header_util'

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

export const load = (async ({ fetch, url, params: { dict } }) => {
  const dict_path = api_path('v1dict.show', dict)
  const dinfo = await api_get<V1Dict>(dict_path, fetch)

  const query = gen_query(dict, url.searchParams)
  const terms_url = api_path('v1defn.index', null, url.searchParams, query)
  const terms = await api_get<TermsData>(terms_url, fetch)

  const _meta = {
    title: 'Từ điển:' + dinfo.label,
    left_nav: [
      home_nav('ps'),
      nav_link('/mt/dicts', 'Từ điển', 'package', { show: 'ts' }),
      nav_link(dict, dinfo.label, '', { kind: 'title' }),
    ],
  }

  return { ...dinfo, ...terms, query, _meta }
}) satisfies PageLoad

function gen_query(dic: string, params: URLSearchParams) {
  return {
    dic: dic,
    key: params.get('key') || '',
    val: params.get('val') || '',
    ptag: params.get('ptag') || '',
    prio: +params.get('prio') || '',
    tab: +params.get('tab') || '',
    uname: params.get('uname') || '',
    pg: +params.get('pg') || 1,
    lm: +params.get('lm') || 50,
  }
}
