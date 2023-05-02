import { api_get } from '$lib/api_call'
import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

interface VilistData extends CV.Paginate {
  list: CV.Vilist
  user: CV.Viuser

  books: CV.VicritList
}

export const load = (async ({ url, fetch, params }) => {
  const user = params.user
  const l_id = parseInt(params.list, 10)

  const path = `/_db/lists/${l_id}${url.search}`

  const data = await api_get<VilistData>(path, fetch)

  data.books.users = { [data.user.vu_id]: data.user }
  data.books.lists = { [data.list.id]: data.list }

  const { id, title, tslug } = data.list

  const curr_path = `${id}-${tslug}`
  const _meta: App.PageMeta = {
    left_nav: [
      nav_link(`/@${user}`, `@${user}`, ''),
      nav_link(`/@${user}/ul`, 'Thư đơn', 'bookmarks', { show: 'tm' }),
      nav_link(curr_path, title, 'article', {
        kind: 'title',
        show: 'pl',
      }),
    ],
    right_nav: [nav_link('/uc', 'Đánh giá', 'stars', { show: 'tm' })],
  }

  const _board = `vl:${l_id}`
  return { ...data, _meta, _title: `Thư đơn: ${title}`, _board }
}) satisfies PageLoad
