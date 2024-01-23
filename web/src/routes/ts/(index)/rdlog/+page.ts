import { nav_link } from '$utils/header_util'
import { merge_query, api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

interface JsonData extends CV.Paginate {
  items: Array<CV.Rdmemo & CV.Tsrepo>
}

export const load = (async ({ url: { searchParams }, fetch }) => {
  const filter = {
    lm: 15,
    rtype: 'rdlog',
    stype: searchParams.get('stype') || '',
  }
  const search = merge_query(searchParams, filter)

  const path = `/_rd/rdmemos?${search.toString()}`
  const data = await api_get<JsonData>(path, fetch)

  return {
    props: data,
    filter,
    ontab: 'rdlog',
    _title: `Lịch sử đọc tryện`,
    _meta: {
      left_nav: [
        nav_link(`/ts`, 'Đọc truyện', 'book', { show: 'pl' }),
        nav_link('/ts/rdlog', 'Lịch sử đọc', 'history'),
      ],
    },
  }
}) satisfies PageLoad
