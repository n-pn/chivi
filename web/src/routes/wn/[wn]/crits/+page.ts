import type { PageLoad } from './$types'
import { load_crits } from '$lib/fetch_data'

export const load = (async ({ url, fetch, parent }) => {
  const { nvinfo, _navs } = await parent()

  const qdata = {
    wn: nvinfo.id,
    by: url.searchParams.get('by'),
    og: url.searchParams.get('og') || 'mixed',
    gt: +url.searchParams.get('gt') || 1,
    lt: +url.searchParams.get('lt') || 5,
    pg: +url.searchParams.get('pg') || 1,
    _s: url.searchParams.get('_s') || 'score',
    _m: url.searchParams.get('_m'),
  }

  const limit = qdata.og == 'mixed' ? 4 : 8
  const query = (url.search || '?_s=score') + `&lm=${limit}&wn=${nvinfo.id}`

  const { vdata, ydata } = await load_crits(qdata.og, query, fetch)

  return {
    vdata,
    ydata,
    qdata,
    ontab: 'crits',
    _meta: { title: `Đánh giá truyện: ${nvinfo.vtitle}` },
    _prev: { show: 'pl' },
    _navs: [
      ..._navs,
      {
        href: `/wn/${nvinfo.id}/crits`,
        text: 'Đánh giá',
        icon: 'stars',
        kind: 'title',
      },
    ],
    _alts: [
      {
        href: `/uc/crits/+crit?wn=${nvinfo.id}`,
        text: 'Tạo mới',
        icon: 'square-plus',
        kind: 'success',
        hshow: 'tm',
      },
    ],
  }
}) satisfies PageLoad
