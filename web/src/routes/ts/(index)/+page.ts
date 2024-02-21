import { merge_query, api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

interface JsonData extends CV.Paginate {
  repos: CV.Tsrepo[]
  memos: Record<number, CV.Rdmemo>
}
export const load = (async ({ url, fetch, parent }) => {
  const state = +url.searchParams.get('state') || -1
  const extras = { lm: 24, state, order: 'mtime' }
  const query = merge_query(url.searchParams, extras)
  const table = await api_get<JsonData>(`/_rd/tsrepos?${query}`, fetch)

  return {
    table,
    state,
    ontab: 'index',
    _meta: { title: `Nội dung chương tiết` },
  }
}) satisfies PageLoad
