import { merge_query, api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load: PageLoad = (async ({ fetch, params, url }) => {
  const sort = url.searchParams.get('sort') || 'utime'
  const user = params.user

  const opts = merge_query(url.searchParams, { user, lm: 10 })
  const path = `/_db/crits?${opts.toString()}`
  const vi = await api_get<CV.VicritList>(path, fetch)

  const _title = 'Đánh giá truyện'
  // FIXME: add _mdesc and _image here

  const _meta: App.PageMeta = {
    left_nav: [
      home_nav('tm'),
      nav_link(`/@${user}`, `@${user}`, ''),
      nav_link(`/@${user}/crits`, 'Đánh giá', 'stars'),
    ],
    right_nav: [
      nav_link(`/@${user}/lists`, 'Thư đơn', 'bookmarks', { show: 'tm' }),
    ],
  }

  return { vi, sort, _title, _meta }
}) satisfies PageLoad
