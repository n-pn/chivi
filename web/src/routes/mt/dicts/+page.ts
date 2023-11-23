import { api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

interface JsonData extends CV.Paginate {
  dicts: CV.Zvdict[]
}

const _meta: App.PageMeta = {
  left_nav: [home_nav(), nav_link('dicts', 'Từ điển', 'package')],
}

export const load = (async ({ fetch, url }) => {
  const kind = url.searchParams.get('kind') || ''
  const path = `/_ai/dicts${url.search || '?pg=1'}&lm=30`
  const data = await api_get<JsonData>(path, fetch)
  return { ...data, kind, _meta, _title: 'Từ điển', _ontab: kind || 'cv' }
}) satisfies PageLoad
