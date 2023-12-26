import { api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

interface Vcdata {
  crit: CV.Vicrit
  book: CV.Wninfo
}
export const load = (async ({ fetch, params: { crit } }) => {
  const vcpath = `/_db/crits/${crit}`
  const vcdata = await api_get<Vcdata>(vcpath, fetch)

  const rppath = `/_db/droots/show/vc:${crit}`
  const { rplist } = await api_get<CV.GdrootPage>(rppath, fetch)

  const _meta = {
    left_nav: [
      nav_link('/wn/crits', 'Đánh giá truyện', 'stars', { show: 'tm' }),
      nav_link(`/wn/crits/v${crit}`, `v${crit}`, 'article', { kind: 'zseed' }),
    ],
    right_nav: [nav_link('/wn/lists', 'Thư đơn', 'bookmarks', { show: 'tm' })],
  }

  return {
    vcdata,
    rplist,
    _meta,
    _title: `Đánh giá truyện của [@${vcdata.crit.u_uname}]`,
    _mdesc: `Đánh giá cho bộ truyện ${vcdata.crit.b_title}`,
  }
}) satisfies PageLoad