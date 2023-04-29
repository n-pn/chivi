import { merge_query, api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load: PageLoad = (async ({ fetch, params, url }) => {
  const user = params.user
  const search = merge_query(url.searchParams, { user, lm: 10 })
  const path = '/_db/crits?' + search.toString()

  const data = await api_get<CV.VicritList>(path, fetch)

  const _title = 'Đánh giá truyện'
  // FIXME: add _mdesc and _image here

  const _meta: App.PageMeta = {
    left_nav: [home_nav('tm'), nav_link(`/@${user}/uc`, 'Đánh giá', 'stars')],
    right_nav: [
      nav_link(`/@${user}/ul`, 'Thư đơn', 'bookmarks', { show: 'tm' }),
    ],
  }

  return { ...data, _title, _meta }
}) satisfies PageLoad
