import { api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

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
  const path = `/_m1/dicts${url.search}`
  const data = await api_get<JsonData>(path, fetch)

  return { ...data, _meta }
}) satisfies PageLoad
