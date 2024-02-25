import { merge_query, api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

interface Data extends CV.Paginate {
  items: CV.Zvpair[]
  start: number
}

export const load = (async ({ params, fetch, url }) => {
  const dname = params.name
  const search = merge_query(url.searchParams, { dname, lm: 50 })
  const data = await api_get<Data>(`/_ai/zvpairs?${search}`, fetch)
  return {
    ...data,
    query: gen_query(url.searchParams),
    _meta: { title: 'Nghĩa cặp từ' },
    _alts: [{ href: `${url.pathname}/+pair`, text: 'Thêm mới', icon: 'plus', show: 'pl' }],
  }
}) satisfies PageLoad

function gen_query(params: URLSearchParams) {
  return {
    a_key: params.get('a_key') || '',
    b_key: params.get('b_key') || '',
    uname: params.get('uname') || '',
  }
}
