import { api_path, api_get } from '$lib/api_call'
import type { PageLoadEvent } from './$types'

// FIXME: add type for term
export interface TermsData extends CV.Paginate {
  start: number
  terms: any[]
}

export interface V1Dict {
  dname: string
  label: string
  brief: string

  dsize: number
  users: string[]
}

export async function load({ fetch, url, params: { dict } }: PageLoadEvent) {
  const dict_path = api_path('v1dict.show', dict)
  const dinfo = await api_get<V1Dict>(dict_path, fetch)

  const query = gen_query(dict, url.searchParams)
  const terms_url = api_path('v1defn.index', null, url.searchParams, query)
  const terms = await api_get<TermsData>(terms_url, fetch)

  return { ...dinfo, ...terms, query }
}

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
