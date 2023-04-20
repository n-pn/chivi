import { load_crits } from '$lib/fetch_data'
import { home_nav, book_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ url, fetch, params, parent }) => {
  const sort = url.searchParams.get('sort') || 'score'
  const data = await load_crits(url, fetch, { sort, book: params.wn_id })

  const { nvinfo } = await parent()

  const _meta = {
    title: `Đánh giá: ${nvinfo.vtitle}`,
    desc: nvinfo.bintro.substring(0, 300),
    left_nav: [
      home_nav('', ''),
      book_nav(nvinfo.bslug, nvinfo.vtitle, 'tm'),
      nav_link('crits', 'Đánh giá', 'stars'),
    ],
    right_nav: [
      nav_link('crits/+crit', 'Đánh giá', 'circle-plus', { show: 'tl' }),
    ],
  }
  return { ...data, sort, _meta }
}) satisfies PageLoad
