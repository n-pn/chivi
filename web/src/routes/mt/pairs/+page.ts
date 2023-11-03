import { nav_link } from '$utils/header_util'
import { merge_query, api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

interface Data extends CV.Paginate {
  items: CV.Zvpair[]
  start: number
}

export const load = (async ({ fetch, url }) => {
  const search = merge_query(url.searchParams, { lm: 50 })
  const data = await api_get<Data>(`/_ai/zvpairs?${search}`, fetch)

  const _meta = {
    left_nav: [
      nav_link('/mt/pairs', 'Nghĩa cặp từ', 'package', { show: 'ts' }),
    ],

    right_nav: [
      nav_link('/mt/pairs/+pair', 'Thêm mới', 'plus', { show: 'ts' }),
    ],
  }

  const query = gen_query(url.searchParams)

  return { ...data, query, _meta, _title: 'Nghĩa cặp từ' }
}) satisfies PageLoad

function gen_query(params: URLSearchParams) {
  return {
    dname: params.get('dname') || '',
    a_key: params.get('a_key') || '',
    b_key: params.get('b_key') || '',
    uname: params.get('uname') || '',
  }
}
