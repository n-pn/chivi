import { load_crits } from '$lib/fetch_data'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ url, fetch, parent }) => {
  const { _user } = await parent()

  if (_user.privi < 1) url.searchParams.append('from', 'vi')
  const sort = url.searchParams.get('sort') || 'utime'
  const data = await load_crits(url, fetch, { sort })

  const _meta = {
    left_nav: [
      home_nav('ts'),
      nav_link('/wn/crits', 'Đánh giá', 'stars', { show: 'ts' }),
    ],
  }

  return { ...data, sort, _meta, _title: 'Đánh giá truyện chữ' }
}) satisfies PageLoad
