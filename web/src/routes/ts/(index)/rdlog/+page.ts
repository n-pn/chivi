import { merge_query, api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

interface JsonData extends CV.Paginate {
  memos: CV.Rdmemo[]
  repos: Record<number, CV.Tsrepo>
}

export const load = (async ({ url: { searchParams }, fetch, parent }) => {
  const filter = {
    lm: 15,
    rtype: 'rdlog',
    stype: searchParams.get('stype') || '',
  }
  const search = merge_query(searchParams, filter)

  const rpath = `/_rd/rdmemos?${search.toString()}`
  const table = await api_get<JsonData>(rpath, fetch)

  const { _navs } = await parent()

  return {
    table,
    filter,
    ontab: 'rdlog',
    _meta: { title: `Lịch sử đọc tryện` },
    _navs: [..._navs, { link: '/ts/rdlog', text: 'Lịch sử đọc', icon: 'history' }],
  }
}) satisfies PageLoad
