import { api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

interface YcritData {
  crit: CV.Yscrit
  user: CV.Ysuser
  book?: CV.Crbook
  list?: CV.Yslist
}
export const load = (async ({ url, fetch, params: { id } }) => {
  const ycrit = await api_get<YcritData>(`/_ys/crits/${id}`, fetch)

  const pg = +url.searchParams.get('pg') || 1
  const rpurl = `/_ys/repls/${id}?pg=${pg}&lm=100`
  const repls = await api_get<CV.Ysrepl[]>(rpurl, fetch)

  return {
    ycrit,
    repls,
    ontab: 'ysapp',
    _meta: { title: `Đánh giá [${id}] - ${ycrit.book?.vtitle}` },
    _navs: [
      // nav_link(`/wn/crits`, 'Đánh giá', 'stars', { show: 'pl' }),
      // nav_link(`/wn/crits/y${crit}`, `y${crit}`, 'article', {
      //   kind: 'zseed',
      // }),
    ],
  }
}) satisfies PageLoad
