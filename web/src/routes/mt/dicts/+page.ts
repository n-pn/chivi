import { api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

interface JsonData extends CV.Paginate {
  dicts: CV.Vidict[]
}

const _meta: App.PageMeta = {
  left_nav: [home_nav('ps'), nav_link('dicts', 'Từ điển', 'package')],
}

export const load = (async ({ fetch, url }) => {
  const path = `/_ai/dicts${url.search}`
  const data = await api_get<JsonData>(path, fetch)

  return { ...data, _meta, _title: 'Từ điển' }
}) satisfies PageLoad
