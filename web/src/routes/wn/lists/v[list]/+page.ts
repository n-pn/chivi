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

  const data = await api_get<VilistData>(path, fetch)

  data.books.users = { [data.user.vu_id]: data.user }
  data.books.lists = { [data.list.vl_id]: data.list }

  const { title, tslug } = data.list

  const _meta: App.PageMeta = {
    left_nav: [
      home_nav('tm', ''),
      nav_link('/wn/lists', 'Thư đơn', 'bookmarks', { show: 'tm' }),
      nav_link(`v${tslug}`, title, null, { kind: 'title' }),
    ],
    right_nav: [nav_link('/wn/crits', 'Đánh giá', 'stars', { show: 'tm' })],
  }

  const _board = `vl:${l_id}`
  return { ...data, _meta, _title: `Thư đơn: ${title}`, _board }
}) satisfies PageLoad
