import { api_path } from '$lib/api_call'
import { make_vdict } from '$utils/vpdict_utils'

// FIXME: add type for term
export interface JsonData extends CV.Paginate {
  dname: string
  d_dub: string
  d_tip: string
  dsize: number
  start: number
  terms: any[]
}

const fields = ['key', 'val', 'ptag', 'prio', 'uname', '_mode']

export async function load({ fetch, url, params: { dict } }) {
  const path = api_path('v1dict.show', dict, url.searchParams, { lm: 50 })
  const data: JsonData = await fetch(path).then((r: Response) => r.json())

  const { d_dub, d_tip } = make_vdict(dict, data.d_dub)

  const query = {}
  for (const field in fields) query[field] = url.searchParams.get(field) || ''

  // prettier-ignore
  const _meta: App.PageMeta = {
    title: 'Từ điển:' + d_dub,
    left_nav: [
      { text: 'Từ điển', icon: 'package', href: '/dicts', 'data-show': 'ts' },
      { text: d_dub, href: url.pathname, 'data-kind': 'title' },
    ],
  }

  return { ...data, d_dub, d_tip, query, _meta }
}
