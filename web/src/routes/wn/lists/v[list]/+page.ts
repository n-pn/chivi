import { api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

interface VilistData extends CV.Paginate {
  list: CV.Vilist
  user: CV.Viuser

  books: CV.VicritList
}

export const load = (async ({ url, fetch, params }) => {
  const l_id = parseInt(params.list, 10)
  const path = `/_db/lists/${l_id}${url.search}`

  const { list, books } = await api_get<VilistData>(path, fetch)

  const { title, tslug } = list

  const _meta: App.PageMeta = {
    left_nav: [
      nav_link('/wn/lists', 'Thư đơn', 'bookmarks', { show: 'tm' }),
      nav_link(`v${tslug}`, title, null, { kind: 'title' }),
    ],
    right_nav: [nav_link('/wn/crits', 'Đánh giá', 'stars', { show: 'tm' })],
  }

  return { list, books, _meta, _title: `Thư đơn: ${title}` }
}) satisfies PageLoad
