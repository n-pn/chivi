import { api_path, api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$gui/global/header_util'

import type { PageLoad } from './$types'

const _meta = {
  title: 'Thư đơn',
  left_nav: [home_nav('tm'), nav_link('/ys/lists', 'Thư đơn', 'bookmarks')],
  right_nav: [nav_link('/ys/crits', 'Đánh giá', 'stars', { show: 'tm' })],
}

export const load = (async ({ fetch, url: { searchParams } }) => {
  const path = api_path('yslists.index', {}, searchParams, { lm: 10 })
  const data = await api_get<CV.YslistList>(path, fetch)

  const params = Object.fromEntries(searchParams)
  return { ...data, _meta, params: params }
}) satisfies PageLoad
