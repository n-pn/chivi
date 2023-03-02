import { api_path, api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$gui/global/header_util'

import type { PageLoad } from './$types'

export type DictInfo = [string, string, number]

interface JsonData extends CV.Paginate {
  cores: DictInfo[]
  books: DictInfo[]
}

const _meta: App.PageMeta = {
  title: 'Từ điển',
  left_nav: [home_nav('ps'), nav_link('dicts', 'Từ điển', 'package')],
}

export const load = (async ({ fetch, url }) => {
  const path = api_path('v1dict.index', 0, url.searchParams)

  // FIXME: update api result
  const data: JsonData = await api_get<JsonData>(path, fetch)

  return { ...data, _meta }
}) satisfies PageLoad
