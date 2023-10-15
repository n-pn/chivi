import { load_crits } from '$lib/fetch_data'
import { home_nav, book_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ url, fetch, params, parent }) => {
  const book = parseInt(params.wn, 10)
  const sort = url.searchParams.get('sort') || 'score'

  const data = await load_crits(url, fetch, { book, sort })

  const { nvinfo } = await parent()

  const _meta = {
    left_nav: [
      book_nav(nvinfo.bslug, nvinfo.vtitle, 'tm'),
      nav_link('uc', 'Đánh giá', 'stars', { show: 'pm' }),
    ],
  }
  return {
    ...data,
    sort,
    ontab: 'uc',
    _meta,
    _title: `Đánh giá: ${nvinfo.vtitle}`,
  }
}) satisfies PageLoad
