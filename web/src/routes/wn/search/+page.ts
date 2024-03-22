import { api_get, merge_query } from '$lib/api_call'
import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

interface JsonData extends CV.Paginate {
  books: CV.Wninfo[]
}

export const load = (async ({ fetch, url: { searchParams } }) => {
  const type = searchParams.get('t') || 'btitle'
  const input = searchParams.get('q').replaceAll('+', ' ')

  const extras = { order: 'weight', lm: 8, [type]: input }
  const query = merge_query(searchParams, extras)

  const data = await api_get<JsonData>(`/_db/books?${query}`, fetch)

  //     nav_link('/wn', 'Thư viện', 'books', { show: 'md' }),

  return {
    ...data,
    input,
    type,
    _meta: { title: `Kết quả tìm kiếm cho "${input}"` },
  }
}) satisfies PageLoad
