import { api_get } from '$lib/api_call'
import { Pager } from '$lib/pager'

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

  const qdata = {
    by: list.u_uname,
    og: 'chivi',
    gt: +url.searchParams.get('gt') || 1,
    lt: +url.searchParams.get('lt') || 5,
    pg: +url.searchParams.get('pg') || 1,
    _s: url.searchParams.get('_s') || 'utime',
    _m: url.searchParams.get('_m'),
  }

  return {
    list,
    books,
    qdata,
    pager: new Pager(url, qdata),
    _meta: {
      title: `Thư đơn: ${list.title}`,
      mdesc: list.dhtml.substring(0, 150),
    },
    _curr: { text: list.title },
    _navs: [
      ..._navs,
      {
        href: `/uc/lists/v${l_id}`,
        text: `ID: v${l_id}`,
        kind: 'title',
      },
    ],
  }
}) satisfies PageLoad
