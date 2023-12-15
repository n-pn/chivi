import { api_get } from '$lib/api_call'
import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ fetch, params: { wn, crit }, parent }) => {
  const { nvinfo } = await parent()

  const _meta = {
    left_nav: [
      nav_link(`/wn/${wn}/uc`, 'Đánh giá', 'stars', { show: 'pl' }),
      nav_link(crit, `[${crit}]`, null, { kind: 'zseed' }),
    ],
  }

  return {
    ycrit: api_get<CV.YscritFull>(`/_ys/crits/${crit}`, fetch),
    repls: api_get<CV.Ysrepl[]>(`/_ys/repls/${crit}`, fetch),
    _meta,
    _title: `Đánh giá [${crit}] - ${nvinfo.vtitle}`,
  }
}) satisfies PageLoad
