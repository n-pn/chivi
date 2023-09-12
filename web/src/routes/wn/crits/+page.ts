import { load_crits } from '$lib/fetch_data'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ url, fetch, parent }) => {
  const sort = url.searchParams.get('sort') || 'utime'
  const data = await load_crits(url, fetch, { sort })

  const { _user } = await parent()
  const _meta = build_meta(_user)

  return { ...data, sort, _meta, _title: 'Đánh giá truyện chữ' }
}) satisfies PageLoad

const build_meta = (user: App.CurrentUser) => {
  const right_nav = []

  if (user.privi >= 0) {
    const href = `/wn/crits?from=vi&user=${user.uname}`
    right_nav.push(nav_link(href, 'Của bạn', 'at', { show: 'tm' }))
  }

  return {
    left_nav: [
      home_nav('ts'),
      nav_link('/wn/crits', 'Đánh giá', 'stars', { show: 'ts' }),
    ],
    right_nav,
  }
}