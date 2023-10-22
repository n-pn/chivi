import { load_lists } from '$lib/fetch_data'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ url, fetch }) => {
  const data = await load_lists(url, fetch)
  const _meta = {
    left_nav: [home_nav(), nav_link('/wn/lists', 'Thư đơn', 'bookmarks')],
  }

  const filter = { qs: url.searchParams.get('qs') }

  return { ...data, filter, _meta, _title: 'Thư đơn truyện chữ', ontab: 'home' }
}) satisfies PageLoad
