import { nav_link } from '$utils/header_util'
import { merge_query, api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

interface JsonData extends CV.Paginate {
  items: CV.Tsrepo[]
}

export const load = (async ({ url: { searchParams }, fetch }) => {
  const state = +searchParams.get('state') || 0
  const query = merge_query(searchParams, { lm: 24, state, order: 'rtime' })
  const table = await api_get<JsonData>(`/_rd/rdmemos?${query}`, fetch)

  return {
    table,
    state,
    ontab: 'track',
    _title: `Đang theo dõi`,
    _meta: {
      left_nav: [
        nav_link(`/ts`, 'Đọc truyện', 'book', { show: 'ts' }),
        nav_link('/ts/track', 'Đang theo dõi', 'notebook', { show: 'tm' }),
      ],
    },
  }
}) satisfies PageLoad
