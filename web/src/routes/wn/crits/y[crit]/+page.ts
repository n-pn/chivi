import { api_get } from '$lib/api_call'
import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

interface YcritData {
  crit: CV.Yscrit
  user: CV.Ysuser
  book?: CV.Crbook
  list?: CV.Yslist
}
export const load = (async ({ url, fetch, params: { crit } }) => {
  const ycrit = await api_get<YcritData>(`/_ys/crits/${crit}`, fetch)

  const pg = +url.searchParams.get('pg') || 1
  const rpurl = `/_ys/repls/${crit}?pg=${pg}&lm=200`
  const repls = await api_get<CV.Ysrepl[]>(rpurl, fetch)

  return {
    ycrit,
    repls,

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
