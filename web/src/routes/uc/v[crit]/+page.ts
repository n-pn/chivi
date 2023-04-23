import { api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

interface CritData {
  crit: CV.Vicrit
  book: CV.Wninfo
  list: CV.Vilist
  user: CV.Viuser
  memo: CV.Memoir
}

export const load = (async ({ fetch, params: { crit } }) => {
  const path = `/_db/crits/${crit}`
  const data = await api_get<CritData>(path, fetch)

  const rppath = `/_db/mrepls/thread/vc:${crit}`
  const rplist = await api_get<CV.Rplist>(rppath, fetch)

  const _meta = {
    title: `Đánh giá [${crit}]`,
    desc: `Đánh giá cho bộ truyện ${data.book.vtitle}`,
    left_nav: [
      home_nav('ts'),
      nav_link('/uc', 'Đánh giá truyện', 'stars', { show: 'tm' }),
      nav_link('/uc/v' + crit, `[@${data.user.uname}]`, null, {
        kind: 'zseed',
      }),
    ],
    right_nav: [nav_link('/ul', 'Thư đơn', 'bookmarks', { show: 'tm' })],
  }

  return { ...data, rplist, _meta }
}) satisfies PageLoad
