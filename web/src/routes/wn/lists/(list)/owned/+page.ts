import { load_lists } from '$lib/fetch_data'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ url, fetch, parent }) => {
  const { _user } = await parent()

  const new_url = new URL(url)
  new_url.searchParams.append('from', 'vi')
  new_url.searchParams.append('user', _user.uname)

  const data = await load_lists(new_url, fetch)

  const _meta = {
    left_nav: [home_nav(), nav_link('/wn/lists', 'Thư đơn', 'bookmarks')],
  }

  const filter = { qs: url.searchParams.get('qs') }

  return { ...data, filter, _meta, _title: 'Thư đơn truyện chữ', ontab: 'mine' }
}) satisfies PageLoad

// /wn/lists?from=vi&user=${user.uname}`
