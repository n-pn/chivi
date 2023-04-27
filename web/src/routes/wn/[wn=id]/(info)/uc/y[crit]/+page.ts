import { api_get } from '$lib/api_call'
import { book_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ fetch, params: { crit }, parent }) => {
  const { nvinfo } = await parent()
  const book_path = `/wn/${nvinfo.bslug}`

  const _meta = {
    left_nav: [
      book_nav(book_path, nvinfo.vtitle, 'tm'),
      nav_link(book_path + '/uc', 'Đánh giá', 'stars', { show: 'ts' }),
      nav_link(crit, `[${crit}]`, null, { kind: 'zseed' }),
    ],
    right_nav: [
      nav_link(book_path + '/uc/+crit', 'Tạo mới', 'circle-plus', {
        show: 'tl',
      }),
    ],
  }

  return {
    ycrit: api_get<CV.YscritFull>(`/_ys/crits/${crit}`, fetch),
    repls: api_get<CV.Ysrepl[]>(`/_ys/repls/${crit}`, fetch),
    _meta,
    _title: `Đánh giá truyện [${crit}]`,
  }
}) satisfies PageLoad
