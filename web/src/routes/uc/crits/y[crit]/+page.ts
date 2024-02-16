import { api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

interface YcritData {
  crit: CV.Yscrit
  user: CV.Ysuser
  book?: CV.Crbook
  list?: CV.Yslist
}
export const load = (async ({ url, fetch, params: { crit } }) => {
  const ydata = await api_get<YcritData>(`/_ys/crits/${crit}`, fetch)

  const pg = +url.searchParams.get('pg') || 1
  const rpurl = `/_ys/repls/${crit}?pg=${pg}&lm=100`
  const repls = await api_get<CV.Ysrepl[]>(rpurl, fetch)

  return {
    ydata,
    repls,
    ontab: 'crits',
    _meta: { title: `Đánh giá [${crit}] - ${ydata.book?.vtitle}` },
    _navs: [
      // nav_link(`/uc/crits`, 'Đánh giá', 'stars', { show: 'pl' }),
      // nav_link(`/uc/crits/y${crit}`, `y${crit}`, 'article', {
      //   kind: 'zseed',
      // }),
    ],
  }
}) satisfies PageLoad
