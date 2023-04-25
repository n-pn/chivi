import { api_get, merge_query } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageData } from './$types'

const _meta = {
  left_nav: [home_nav('tm'), nav_link('/gd', 'Diễn đàn', 'messages')],
}

export const load = (async ({ fetch, url }) => {
  const query = merge_query(url.searchParams, { lm: 10 })
  const dtlist = await api_get<CV.Dtlist>(`/_db/topics?${query}`, fetch)

  return { dtlist, _meta, _title: 'Diễn đàn' }
}) satisfies PageData
