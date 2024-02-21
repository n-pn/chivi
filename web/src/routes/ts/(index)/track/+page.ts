import { merge_query, api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

interface JsonData extends CV.Paginate {
  repos: CV.Tsrepo[]
  memos: Record<number, CV.Rdmemo>
}

export const load = (async ({ url: { searchParams }, fetch, parent }) => {
  const state = +searchParams.get('state') || 0
  const stars = +searchParams.get('stars') || 0

  const query = merge_query(searchParams, { lm: 24, state, stars, order: 'mtime' })
  const table = await api_get<JsonData>(`/_rd/tsrepos?${query}`, fetch)

  const { _navs } = await parent()
  return {
    table,
    state,
    ontab: 'track',
    _meta: { title: `Truyện đang theo dõi` },
    _navs: [..._navs, { link: '/ts/track', text: 'Đang theo dõi', icon: 'notebook' }],
  }
}) satisfies PageLoad
