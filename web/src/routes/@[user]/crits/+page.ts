import { merge_query, api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load: PageLoad = (async ({ fetch, params, url }) => {
  const user = params.user
  const search = merge_query(url.searchParams, { user, lm: 10 })
  const path = '/_db/crits?' + search.toString()

  const data = await api_get<CV.VicritList>(path, fetch)

  const _meta: App.PageMeta = {
    title: 'Đánh giá truyện',
    left_nav: [
      home_nav('tm'),
      nav_link(`/@${user}/crits`, 'Đánh giá', 'stars'),
    ],
    right_nav: [
      nav_link(`/@${user}/lists`, 'Thư đơn', 'bookmarks', { show: 'tm' }),
    ],
  }

  return { ...data, _meta }
}) satisfies PageLoad
