import { api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

const _meta = {
  title: 'Thống kê dịch chương',
  left_nav: [
    home_nav('ps'),
    nav_link('/cm/qtran-stat', 'Thống kê dịch chương', ''),
  ],
  right_nav: [nav_link('/cm/qtran-xlog', 'Lịch sử dịch chương', '')],
}

export const load = (async ({ fetch, url }) => {
  const scope = url.searchParams.get('scope') || 'today'
  const path = `/_db/qtran_xlogs/stats?scope=${scope}`

  const data = await api_get<CV.QtranStat>(path, fetch)

  return { ...data, scope, _meta }
}) satisfies PageLoad
