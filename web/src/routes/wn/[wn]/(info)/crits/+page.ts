import type { PageLoad } from './$types'
import { load_crits } from '$lib/fetch_data'

// import { book_nav, nav_link } from '$utils/header_util'

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
  const query = (url.search || '?_s=score') + `&lm=${limit}`

  // const _meta = {
  //   left_nav: [
  //     book_nav(nvinfo.id, nvinfo.vtitle, 'tm'),
  //     nav_link('uc', 'Đánh giá', 'stars', { show: 'pm' }),
  //   ],
  // }
  // return {

  const { vdata, ydata } = await load_crits(qdata.og, query, fetch)

  return {
    vdata,
    ydata,
    qdata,
    ontab: 'crits',
    _meta: { title: `Đánh giá truyện: ${nvinfo.vtitle}` },
    _navs: [
      ..._navs,
      {
        href: `/wn/${nvinfo.id}/crits`,
        text: 'Đánh giá',
        hd_icon: 'stars',
        hd_kind: 'title',
      },
    ],
  }
}) satisfies PageLoad
