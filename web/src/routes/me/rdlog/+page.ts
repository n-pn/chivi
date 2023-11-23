import { nav_link } from '$utils/header_util'
import { merge_query, api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

interface JsonData extends CV.Paginate {
  items: CV.Rdmemo[]
}

export const load = (async ({ url: { searchParams }, fetch }) => {
  const filter = { lm: 15, rtype: 'rdlog', sname: searchParams.get('sn') || '' }
  const search = merge_query(searchParams, filter)

  const path = `/_rd/rdmemos?${search.toString()}`
  const data = await api_get<JsonData>(path, fetch)

  return {
    props: data,
    filter,
    _title: `Lịch sử đọc tryện`,
    _meta: {
      left_nav: [
        nav_link(`/me`, 'Cá nhân', 'user', { show: 'ts' }),
        nav_link('/me/rdlog', 'Lịch sử đọc', 'history', { show: 'tm' }),
      ],
    },
  }
}) satisfies PageLoad
