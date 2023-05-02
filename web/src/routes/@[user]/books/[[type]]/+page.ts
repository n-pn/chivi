import { nav_link } from '$utils/header_util'
import { merge_query, api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

interface JsonData extends CV.Paginate {
  books: CV.Wninfo[]
}

export const load = (async ({ url, params, fetch }) => {
  const { user: uname, type: bmark = 'reading' } = params

  const extras = { lm: 24, order: 'update', uname, bmark }
  const query = merge_query(url.searchParams, extras)

  const data = await api_get<JsonData>(`/_db/books?${query}`, fetch)

  const _title = `Tủ truyện của @${uname}`

  const _meta = {
    left_nav: [
      nav_link(`/@${uname}`, uname, 'user', { show: 'ts' }),
      nav_link(url.pathname, 'Tủ truyện', 'books', { show: 'tm' }),
    ],
    right_nav: [nav_link(`/me/books`, 'Cá nhân', 'at', { show: 'tm' })],
  }

  return { ...data, uname: uname, bmark, _title, _meta }
}) satisfies PageLoad
