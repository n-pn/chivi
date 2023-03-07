import { api_path, api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$gui/global/header_util'

import type { PageLoad } from './$types'

interface CritData {
  ycrit: CV.Yscrit
  ylist: CV.Yslist
  yuser: CV.Ysuser
  vbook: CV.Crbook
  repls: CV.YsRepl[]
}

export const load = (async ({ fetch, params: { crit } }) => {
  const path = api_path('yscrits.show', crit)
  const data = await api_get<CritData>(path, fetch)

  const _meta = {
    title: `Đánh giá [${crit}]`,
    desc: `Đánh giá cho bộ truyện ${data.vbook.btitle}`,
    left_nav: [
      home_nav('', ''),
      nav_link('/wn/crits', 'Đánh giá truyện', 'stars', { show: 'tm' }),
      nav_link(crit, `[${crit}]`, null, { kind: 'zseed' }),
    ],
    right_nav: [nav_link('/wn/lists', 'Thư đơn', 'bookmarks', { show: 'tm' })],
  }

  return { ...data, _meta }
}) satisfies PageLoad
