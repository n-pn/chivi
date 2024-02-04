import { load_ys_crits } from '$lib/fetch_data'

import type { PageLoad } from './$types'

export const load = (async ({ url, fetch }) => {
  const qdata = {
    sort: url.searchParams.get('sort') || 'utime',
    smin: +url.searchParams.get('smin') || 0,
    smax: +url.searchParams.get('smax') || 6,
    pg: +url.searchParams.get('pg') || 1,
  }

  const query = (url.searchParams.toString() || 'sort=utime') + '&lm=10'

  return {
    ydata: await load_ys_crits(query, fetch),
    qdata,
    ontab: 'ysapp',
    _meta: { title: 'Đánh giá truyện chữ từ Ưu Thư Võng' },
  }
}) satisfies PageLoad
