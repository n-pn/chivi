import { api_get } from '$lib/api_call'
import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

interface VilistData extends CV.Paginate {
  list: CV.Vilist
  books: CV.VicritList
}

export const load = (async ({ url, fetch, params }) => {
  const user = params.user
  const l_id = parseInt(params.list, 10)

  const path = `/_db/lists/${l_id}${url.search}`

  const { list, books } = await api_get<VilistData>(path, fetch)

  const _meta: App.PageMeta = {
    left_nav: [
      nav_link(`/@${user}`, `@${user}`, ''),
      nav_link(`/@${user}/ul`, 'Thư đơn', 'bookmarks', { show: 'tm' }),
      nav_link(list.tslug, list.title, 'article', {
        kind: 'title',
        show: 'pl',
      }),
    ],
    // right_nav: [nav_link('/uc', 'Đánh giá', 'stars', { show: 'tm' })],
  }

  const _board = `vl:${l_id}`
  const _title = `Thư đơn: ${list.title}`
  const _image = list.covers[0] || 'blank.webp'
  return { list, books, _meta, _title, _board, _image }
}) satisfies PageLoad
