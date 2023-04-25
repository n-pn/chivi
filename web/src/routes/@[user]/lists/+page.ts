import { load_lists } from '$lib/fetch_data'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ url, fetch, parent }) => {
  const data = await load_lists(url, fetch)

  const { _user } = await parent()
  const _meta = build_meta(_user)

  const params = Object.fromEntries(url.searchParams)
  const _title = 'Thư đơn truyện chữ'

  return { ...data.ys, params, _title, _meta }
}) satisfies PageLoad

const build_meta = (user: App.CurrentUser) => {
  const right_nav = []

  if (user.privi >= 0) {
    const href = `/ul?from=vi&user=${user.uname}`
    right_nav.push(nav_link(href, 'Của bạn', 'at', { show: 'tm' }))
  }

  return {
    left_nav: [
      home_nav('tm'),
      nav_link('/wn', 'Truyện chữ', 'books', { show: 'ts' }),
      nav_link('/ul', 'Thư đơn', 'stars', { show: 'ts' }),
    ],
    right_nav,
  }
}
