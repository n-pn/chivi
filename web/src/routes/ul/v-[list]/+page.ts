import { api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

interface VilistData extends CV.Paginate {
  list: CV.Vilist
  user: CV.Viuser

  books: CV.VicritList
}

export const load = (async ({ url, fetch, params }) => {
  const list = parseInt(params.list)
  const api_url = new URL(url)
  api_url.pathname = `/_db/lists/${list}`

  const data = await api_get<VilistData>(api_url.toString(), fetch)

  data.books.users = { [data.user.vu_id]: data.user }
  data.books.lists = { [data.list.id]: data.list }

  const { id, title, tslug } = data.list
  const uslug = `${id}-${tslug}--${data.user.uname}`

  const _meta: App.PageMeta = {
    title: `Thư đơn: ${title}`,
    left_nav: [
      home_nav('', ''),
      nav_link('/ul', 'Thư đơn', 'bookmarks', { show: 'tm' }),
      nav_link(uslug, title, null, { kind: 'title' }),
    ],
    right_nav: [nav_link('/uc', 'Đánh giá', 'stars', { show: 'tm' })],
  }

  return { ...data, _meta }
}) satisfies PageLoad
