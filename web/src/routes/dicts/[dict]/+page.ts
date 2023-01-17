import { api_path } from '$lib/api_call'
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

const fields = ['key', 'val', 'ptag', 'prio', 'uname', '_mode']

export async function load({ fetch, url, params: { dict } }: PageLoadEvent) {
  const dict_path = api_path('v1dict.show', dict)
  const dinfo: V1Dict = await fetch(dict_path).then((r) => r.json())

  const query = {
    dic: dict,
    key: url.searchParams.get('key') || '',
    val: url.searchParams.get('val') || '',
    ptag: url.searchParams.get('ptag') || '',
    prio: +url.searchParams.get('prio') || '',
    tab: +url.searchParams.get('tab') || '',
    uname: url.searchParams.get('uname') || '',
    pg: +url.searchParams.get('pg') || 1,
    lm: +url.searchParams.get('lm') || 50,
  }

  const terms_url = api_path('v1defn.index', null, url.searchParams, query)

  const terms: TermsData = await fetch(terms_url).then((r) => r.json())

  for (const field in fields) query[field] = url.searchParams.get(field) || ''

  // prettier-ignore
  const _meta: App.PageMeta = {
    title: 'Từ điển:' + dinfo.label,
    left_nav: [
      { text: 'Từ điển', icon: 'package', href: '/dicts', 'data-show': 'ts' },
      { text: dinfo.label, href: url.pathname, 'data-kind': 'title' },
    ],
  }

  return { ...dinfo, ...terms, query, _meta }
}
