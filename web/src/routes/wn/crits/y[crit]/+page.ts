import { api_get } from '$lib/api_call'
import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

interface YcritData {
  crit: CV.Yscrit
  user: CV.Ysuser
  book?: CV.Crbook
  list?: CV.Yslist
}
export const load = (async ({ fetch, params: { crit } }) => {
  const ycrit = await api_get<YcritData>(`/_ys/crits/${crit}`, fetch)

  return {
    ycrit,
    repls: api_get<CV.Ysrepl[]>(`/_ys/repls/${crit}`, fetch),
    _title: `Đánh giá [${crit}] - ${ycrit.book?.vtitle}`,
    _meta: {
      left_nav: [
        nav_link(`/wn/crits`, 'Đánh giá', 'stars', { show: 'pl' }),
        nav_link(`/wn/crits/y${crit}`, `y${crit}`, 'article', {
          kind: 'zseed',
        }),
      ],
    },
  }
}) satisfies PageLoad
