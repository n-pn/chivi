import { api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

interface VilistData extends CV.Paginate {
  list: CV.Vilist
  user: CV.Viuser

  books: CV.VicritList
}

export const load = (async ({ url, fetch, params, parent }) => {
  const l_id = parseInt(params.list, 10)
  const path = `/_db/lists/${l_id}${url.search}`

  const { list, books } = await api_get<VilistData>(path, fetch)
  const { _navs } = await parent()

  return {
    list,
    books,
    _meta: {
      title: `Thư đơn: ${list.title}`,
      mdesc: list.dhtml.substring(0, 150),
    },
    _navs: [
      ..._navs,
      {
        href: `/uc/lists/v${l_id}`,
        text: `ID: v${l_id}`,
        hd_text: list.title,
        hd_kind: 'title',
      },
    ],
  }
}) satisfies PageLoad
