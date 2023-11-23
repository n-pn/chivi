import { nav_link } from '$utils/header_util'
import { merge_query, api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

interface Data extends CV.Paginate {
  items: CV.Zvpair[]
  start: number
}

export const load = (async ({ params, fetch, parent, url }) => {
  const { dinfo } = await parent()
  const dname = params.name

  const search = merge_query(url.searchParams, { dname, lm: 50 })
  const data = await api_get<Data>(`/_ai/zvpairs?${search}`, fetch)

  const _meta = {
    left_nav: [
      nav_link('/mt/dicts', 'Từ điển', 'package', { show: 'ts' }),
      nav_link(dinfo.name, dinfo.label, '', { kind: 'title' }),
    ],

    right_nav: [
      nav_link(`/mt/dicts/${dname}_pair/+pair`, 'Thêm mới', 'plus', {
        show: 'ts',
      }),
    ],
  }

  const query = gen_query(url.searchParams)

  return { ...data, dname, query, _meta, _title: 'Nghĩa cặp từ' }
}) satisfies PageLoad

function gen_query(params: URLSearchParams) {
  return {
    a_key: params.get('a_key') || '',
    b_key: params.get('b_key') || '',
    uname: params.get('uname') || '',
  }
}
