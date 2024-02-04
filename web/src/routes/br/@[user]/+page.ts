import type { PageLoad } from './$types'
import { load_vi_crits } from '$lib/fetch_data'

export const load = (async ({ url, fetch, parent, params: { user } }) => {
  const qdata = {
    sort: url.searchParams.get('sort') || 'utime',
    smin: +url.searchParams.get('smin') || 0,
    smax: +url.searchParams.get('smax') || 6,
    pg: +url.searchParams.get('pg') || 1,
  }

  let query = url.searchParams.toString() || 'sort=utime'
  query += `&lm=10&user=${user}`

  const { _navs } = await parent()

  return {
    vdata: await load_vi_crits(query, fetch),
    qdata,
    ontab: 'users',
    _meta: { title: `Đánh giá truyện chữ của @${user}` },
    _navs: [
      ..._navs,
      {
        href: `@${user}`,
        text: `Đánh giá của @${user}`,
        hd_icon: 'at',
        hd_text: user,
        hd_kind: 'title',
      },
    ],
  }
}) satisfies PageLoad
