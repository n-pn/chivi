import { api_get, merge_query } from '$lib/api_call'
import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

interface JsonData extends CV.Paginate {
  books: CV.Wninfo[]
}

export const load = (async ({ fetch, url, params: { genre } }) => {
  const extras = { lm: 24, order: 'weight', genres: genre }
  const query = merge_query(url.searchParams, extras)

  const data = await api_get<JsonData>(`/_db/books?${query}`, fetch)

  // nav_link(url.pathname, 'Thể loại', 'folder', { kind: 'title' }),

  return {
    ...data,
    genres: genre.split('+'),
    _meta: { title: 'Lọc truyện theo thể loại' },
  }
}) satisfies PageLoad
