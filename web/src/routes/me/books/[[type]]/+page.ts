import { nav_link } from '$utils/header_util'
import { merge_query, api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

interface JsonData extends CV.Paginate {
  books: CV.Wninfo[]
}

export const load = (async ({ url, params, fetch, parent }) => {
  const { _user } = await parent()
  const { type: bmark = 'reading' } = params

  const extras = { lm: 24, order: 'update', uname: _user.uname, bmark }
  const query = merge_query(url.searchParams, extras)

  const data = await api_get<JsonData>(`/_db/books?${query}`, fetch)

  const _title = `Tủ truyện của bạn`

  const _meta = {
    left_nav: [
      nav_link(`/me`, 'Cá nhân', 'user', { show: 'ts' }),
      nav_link(url.pathname, 'Tủ truyện', 'notebook', { show: 'tm' }),
    ],
    right_nav: [
      nav_link(`/@${_user.uname}/books`, 'Công cộng', 'globe', { show: 'tm' }),
    ],
  }

  return { ...data, bmark, _title, _meta }
}) satisfies PageLoad
