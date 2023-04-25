import { api_get, merge_query } from '$lib/api_call'
import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

interface JsonData extends CV.Paginate {
  books: CV.Wninfo[]
}

export const load = (async ({ fetch, url, params: { author } }) => {
  const extras = { author, lm: 8, order: 'weight' }
  const query = merge_query(url.searchParams, extras)

  const data = await api_get<JsonData>(`/_db/books?${query}`, fetch)

  const _meta: App.PageMeta = {
    left_nav: [
      nav_link('/wn', 'Thư viện', 'books', { show: 'md' }),
      nav_link(`/wn/=${author}`, author, 'edit', { kind: 'title' }),
    ],
  }

  return { ...data, author, _meta, _title: `Truyện của tác giả: ${author}` }
}) satisfies PageLoad
