import { api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

interface CritData {
  ycrit: CV.Yscrit
  ylist: CV.Yslist
  yuser: CV.Ysuser
  vbook: CV.Crbook

  repls: CV.Ysrepl[]
  users: Record<number, CV.Ysuser>
}

export const load = (async ({ fetch, params: { crit } }) => {
  const path = `/_ys/crits/${crit}`
  const data = await api_get<CritData>(path, fetch)

  const _meta = {
    left_nav: [
      nav_link('/uc', 'Đánh giá truyện', 'stars', { show: 'tm' }),
      nav_link(crit, `[${crit}]`, null, { kind: 'zseed' }),
    ],
    right_nav: [nav_link('/ul', 'Thư đơn', 'bookmarks', { show: 'tm' })],
  }

  return {
    ...data,
    _meta,
    _title: `Đánh giá [${crit}]`,
    _mdesc: `Đánh giá cho bộ truyện ${data.vbook.vtitle}`,
  }
}) satisfies PageLoad
