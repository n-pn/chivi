import { Pager } from '$lib/pager'

import type { PageLoad } from './$types'

import { load_crits } from '$lib/fetch_data'

export const load = (async ({ url, fetch }) => {
  const qdata = {
    by: url.searchParams.get('by'),
    og: url.searchParams.get('og') || 'mixed',
    gt: +url.searchParams.get('gt') || 1,
    lt: +url.searchParams.get('lt') || 5,
    pg: +url.searchParams.get('pg') || 1,
    _s: url.searchParams.get('_s') || 'utime',
    _m: url.searchParams.get('_m'),
  }

  const limit = qdata.og == 'mixed' ? 4 : 8
  const query = (url.search || '?_s=utime') + `&lm=${limit}`
  const { vdata, ydata } = await load_crits(qdata.og, query, fetch)

  return {
    vdata,
    ydata,
    qdata,
    pager: new Pager(url, { _s: 'score', og: 'mixed', gt: 1, lt: 5, pg: 1 }),
    ontab: 'crits',
    _meta: { title: 'Đánh giá truyện chữ' },
  }
}) satisfies PageLoad
