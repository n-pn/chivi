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

  const _meta = {
    title: `Tủ truyện của @${uname}`,
    left_nav: [
      nav_link(`/@${uname}`, uname, 'user', { show: 'md' }),
      { text: 'Tủ truyện', icon: 'notebook', href: url.pathname },
    ],
  }

  return { ...data, uname: uname, bmark, _meta }
}) satisfies PageLoad
