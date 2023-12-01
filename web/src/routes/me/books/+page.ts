import { nav_link } from '$utils/header_util'
import { merge_query, api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

interface JsonData extends CV.Paginate {
  items: CV.Rdmemo[]
}

export const load = (async ({ url, fetch, parent }) => {
  const { _user } = await parent()

  const state = +url.searchParams.get('state') || -1
  const extras = { lm: 24, state, order: 'rtime' }
  const query = merge_query(url.searchParams, extras)
  const table = await api_get<JsonData>(`/_rd/rdmemos?${query}`, fetch)

  return {
    table,
    state,

    _title: `Tủ truyện của bạn`,
    _meta: {
      left_nav: [
        nav_link(`/me`, 'Cá nhân', 'user', { show: 'ts' }),
        nav_link(url.pathname, 'Tủ truyện', 'notebook', { show: 'tm' }),
      ],
      right_nav: [
        nav_link(`/@${_user.uname}/books`, 'Công cộng', 'globe', {
          show: 'tm',
        }),
      ],
    },
  }
}) satisfies PageLoad
