import { api_path, api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

export type DictInfo = [string, string, number]

interface JsonData extends CV.Paginate {
  cores: DictInfo[]
  books: DictInfo[]
}

const _meta: App.PageMeta = {
  title: 'Từ điển',
  left_nav: [{ text: 'Từ điển', icon: 'package', href: 'dicts' }],
}

export const load = (async ({ fetch, url }) => {
  const path = api_path('v1dict.index', 0, url.searchParams)

  // FIXME: update api result
  const data: JsonData = await api_get<JsonData>(path, fetch)

  return { ...data, _meta }
}) satisfies PageLoad
