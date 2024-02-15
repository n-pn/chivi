import type { PageLoad } from './$types'

import { merge_query, api_get } from '$lib/api_call'
import { status_types } from '$lib/constants'

interface JsonData extends CV.Paginate {
  memos: CV.Rdmemo[]
}

status_types
export const load = (async ({ url, params: { user }, fetch }) => {
  const pg_no = +url.searchParams.get('pg') || 1
  const state = status_types.indexOf(url.searchParams.get('st'))

  const rdurl = `/_rd/rdmemos/reading?lm=25&pg=${pg_no}&vu=${user}&st=${state}`
  const { memos, pgidx, pgmax } = await api_get<JsonData>(rdurl, fetch)

  const b_ids = memos.map((x) => x.sn_id).join(',') || '-1'
  const books = await api_get<CV.Wninfo[]>(`/_db/books/all/${b_ids}`, fetch)

  return {
    memos,
    books,
    pgidx,
    pgmax,
    state,
    ontab: 'book',
    _meta: { title: `Tủ truyện của @${user}` },
    _navs: [
      { link: `/@${user}`, text: user, icon: 'at', show: 'ts' },
      { link: `/@${user}/books`, text: 'Tủ truyện', icon: 'books', show: 'tm' },
    ],
  }
}) satisfies PageLoad
