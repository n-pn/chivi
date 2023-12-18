import { load_lists } from '$lib/fetch_data'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ url, fetch, parent, params: { type } }) => {
  const { _user } = await parent()

  const new_url = new URL(url)
  if (type == 'owned') {
    new_url.searchParams.append('from', 'vi')
    new_url.searchParams.append('user', _user.uname)
  }

  const data = await load_lists(new_url, fetch)

  return {
    ...data,
    filter: { qs: url.searchParams.get('qs') },
    ontab: type || 'index',
    _meta: {
      left_nav: [home_nav(), nav_link('/wn/lists', 'Thư đơn', 'bookmarks')],
    },
    _title: 'Thư đơn truyện chữ',
  }
}) satisfies PageLoad

// /wn/lists?from=vi&user=${user.uname}`
