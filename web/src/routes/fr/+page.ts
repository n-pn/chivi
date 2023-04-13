import { home_nav, nav_link } from '$gui/global/header_util'

import { api_get, api_path, merge_query } from '$lib/api_call'
import type { PageData } from './$types'

export const load = (async ({ fetch, url }) => {
  const query = merge_query(url.searchParams, { lm: 10 })
  const path = api_path(`/_db/topics?${query.toString()}`)
  const dtlist = await api_get<CV.Dtlist>(path, fetch)

  const _meta = {
    title: 'Diễn đàn',
    left_nav: [home_nav('tm'), nav_link('/fr', 'Diễn đàn', 'messages')],
  }
  return { dtlist, _meta }
}) satisfies PageData
