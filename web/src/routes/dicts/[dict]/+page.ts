import { make_vdict } from '$utils/vpdict_utils'

function make_query(params: URLSearchParams) {
  return {
    key: params.get('key') || '',
    val: params.get('val') || '',
    ptag: params.get('ptag') || '',
    prio: params.get('prio') || '',
    uname: params.get('uname') || '',
    _mode: params.get('_mode') || '',
  }
}

// FIXME: add type for term
export interface JsonData extends CV.Paginate {
  dname: string
  d_dub: string
  d_tip: string
  dsize: number
  start: number
  terms: any[]
}

export async function load({ fetch, url, params: { dict } }) {
  const api_url = `/api/dicts/${dict}${url.search}`
  const api_res = await fetch(api_url)

  const props = (await api_res.json()).props as JsonData
  const { d_dub, d_tip } = make_vdict(dict, props.d_dub)

  const query = make_query(url.searchParams)

  // prettier-ignore
  const _meta: App.PageMeta = {
    title: 'Từ điển:' + d_dub,
    left_nav: [
      { text: 'Từ điển', icon: 'package', href: '/dicts', 'data-show': 'ts' },
      { text: d_dub, href: url.pathname, 'data-kind': 'title' },
    ],
  }

  return { ...props, d_dub, d_tip, query, _meta }
}
