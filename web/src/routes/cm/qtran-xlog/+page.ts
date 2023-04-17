import { api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$gui/global/header_util'

import type { PageLoad } from './$types'

const _meta = {
  title: 'Lịch sử dịch chương',
  left_nav: [home_nav('ps'), nav_link('/cm/qtran-xlog', 'Lịch sử qtran', '')],
  right_nav: [nav_link('/cm/vcoin-xlog', 'Lịch sử vcoin', '')],
}

export const load = (async ({ fetch, url }) => {
  const path = `/_db/qtran_xlogs${url.search}`
  const data = await api_get<CV.QtranXlogPage>(path, fetch)

  return { ...data, _meta }
}) satisfies PageLoad
