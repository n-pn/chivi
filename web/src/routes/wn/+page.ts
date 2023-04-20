import { api_get, merge_query } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

interface BookList extends CV.Paginate {
  books: CV.Wninfo[]
}

export const load = (async ({ url, fetch }) => {
  const query = merge_query(url.searchParams, { lm: 24 })
  const data = await api_get<BookList>(`/_db/books?${query}`, fetch)

  const _meta = {
    title: 'Danh sách truyện',
    left_nav: [
      home_nav('tm'),
      nav_link('/wn', 'Danh sách truyện', 'books', { kind: 'title' }),
    ],
    right_nav: [
      nav_link('/wn/+book', 'Thêm truyện', 'file-plus', { show: 'tm' }),
    ],
  }

  return { ...data, _meta }
}) satisfies PageLoad
