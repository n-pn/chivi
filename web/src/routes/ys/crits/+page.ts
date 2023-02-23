import { api_path, api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$gui/global/header_util'

import type { PageLoad } from './$types'

const _meta: App.PageMeta = {
  title: 'Đánh giá truyện',
  left_nav: [home_nav('tm'), nav_link('/ys/crits', 'Đánh giá', 'stars')],
  right_nav: [nav_link('/ys/lists', 'Thư đơn', 'bookmarks', { show: 'tm' })],
}

export const load: PageLoad = async ({ fetch, url: { searchParams } }) => {
  const path = api_path('yscrits.index', null, searchParams, { lm: 10 })
  const data = await api_get<CV.YscritList>(path, fetch)
  return { ...data, _meta }
}
