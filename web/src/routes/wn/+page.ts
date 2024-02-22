import { api_get, merge_query } from '$lib/api_call'

import type { PageLoad } from './$types'

interface BookList extends CV.Paginate {
  books: CV.Wninfo[]
}

export const load = (async ({ url, fetch }) => {
  const query = merge_query(url.searchParams, { lm: 24 })
  const data = await api_get<BookList>(`/_db/books?${query}`, fetch)

  return {
    ...data,
    _meta: { title: 'Thư viện truyện chữ' },
    _navs: [{ href: '/wn', text: 'Thư viện', icon: 'books', kind: 'title' }],
    _alts: [{ href: '/wn/+book', text: 'Thêm truyện', icon: 'file-plus', show: 'ts' }],
  }
}) satisfies PageLoad
