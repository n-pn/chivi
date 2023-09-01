import { merge_query, api_get } from '$lib/api_call'

import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ url, fetch, params }) => {
  const user = params.user
  const search = merge_query(url.searchParams, { user, lm: 10 })
  const path = '/_db/lists?' + search.toString()

  const vi = await api_get<CV.VilistList>(path, fetch)

  const _meta: App.PageMeta = {
    left_nav: [
      home_nav('tm'),
      nav_link(`/@${user}`, `@${user}`, ''),
      nav_link(`/@${user}/lists`, 'Thư đơn', 'bookmarks'),
    ],
    right_nav: [
      nav_link(`/@${user}/crits`, 'Đánh giá', 'stars', { show: 'tm' }),
    ],
  }

  // const params = Object.fromEntries(url.searchParams)
  const _title = 'Thư đơn truyện chữ'

  const sort = url.searchParams.get('sort') || 'utime'
  const filter = { qs: url.searchParams.get('qs'), sort }

  return { vi, filter, _title, _meta }
}) satisfies PageLoad
