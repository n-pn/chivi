import { api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

interface CritData {
  crit: CV.Vicrit
  book: CV.Wninfo
  list: CV.Vilist
  user: CV.Viuser
}

export const load = (async ({ fetch, params: { crit } }) => {
  const path = `/_db/crits/${crit}`
  const data = await api_get<CritData>(path, fetch)

  const _meta = {
    title: `Đánh giá [${crit}]`,
    desc: `Đánh giá cho bộ truyện ${data.book.vtitle}`,
    left_nav: [
      nav_link('/uc', 'Đánh giá truyện', 'stars', { show: 'tm' }),
      nav_link(crit, `[${crit}]`, null, { kind: 'zseed' }),
    ],
    right_nav: [nav_link('/ul', 'Thư đơn', 'bookmarks', { show: 'tm' })],
  }

  return { ...data, _meta }
}) satisfies PageLoad
