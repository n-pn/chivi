import { load_crits } from '$lib/fetch_data'
import { home_nav, nav_link } from '$gui/global/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ url, fetch, parent }) => {
  const data = await load_crits(url, fetch)

  const { _user } = await parent()
  const _meta = build_meta(_user)

  return { ...data, _meta }
}) satisfies PageLoad

const build_meta = (user: App.CurrentUser) => {
  const right_nav = []

  if (user.privi >= 0) {
    const href = `/wn/crits?from=vi&user=${user.uname}`
    right_nav.push(nav_link(href, 'Của bạn', 'at', { show: 'tm' }))
  }

  return {
    title: 'Đánh giá truyện chữ',
    left_nav: [
      home_nav('tm'),
      nav_link('/wn', 'Truyện chữ', 'books', { show: 'ts' }),
      nav_link('/wn/crits', 'Đánh giá', 'stars', { show: 'ts' }),
    ],
    right_nav,
  }
}
