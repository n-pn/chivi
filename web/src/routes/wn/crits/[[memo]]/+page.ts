import { load_crits } from '$lib/fetch_data'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ url, fetch, params: { memo } }) => {
  const sort = url.searchParams.get('sort') || 'utime'
  const from = url.searchParams.get('from') || 'vi'

  const data = await load_crits(url, fetch, { sort, memo, from })

  const _meta = {
    left_nav: [
      home_nav('ts'),
      nav_link('/wn/crits', 'Đánh giá', 'stars', { show: 'ts' }),
    ],
  }

  const ontab = memo || 'index'
  return { ...data, sort, ontab, _meta, _title: 'Đánh giá truyện chữ' }
}) satisfies PageLoad
