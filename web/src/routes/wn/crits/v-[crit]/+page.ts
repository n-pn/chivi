import { api_path, api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$gui/global/header_util'

import type { PageLoad } from './$types'

interface CritData {
  crit: CV.Vicrit
  book: CV.Nvinfo
  list: CV.Vilist
  user: CV.Viuser
}

export const load = (async ({ fetch, params: { crit } }) => {
  const path = `/_db/crits/${crit}`
  const data = await api_get<CritData>(path, fetch)

  const _meta = {
    title: `Đánh giá [${crit}]`,
    desc: `Đánh giá cho bộ truyện ${data.book.btitle_vi}`,
    left_nav: [
      home_nav('', ''),
      nav_link('/ys/crits', 'Đánh giá truyện', 'stars', { show: 'tm' }),
      nav_link(crit, `[${crit}]`, null, { kind: 'zseed' }),
    ],
    right_nav: [nav_link('/ys/lists', 'Thư đơn', 'bookmarks', { show: 'tm' })],
  }

  return { ...data, _meta }
}) satisfies PageLoad
