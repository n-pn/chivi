import type { PageLoad } from './$types'
import { load_vi_crits } from '$lib/fetch_data'

export const load = (async ({ url, fetch, parent }) => {
  const qdata = {
    sort: url.searchParams.get('sort') || 'utime',
    smin: +url.searchParams.get('smin') || 0,
    smax: +url.searchParams.get('smax') || 6,
    pg: +url.searchParams.get('pg') || 1,
  }

  const query = (url.searchParams.toString() || 'sort=utime') + '&lm=10'
  const { _navs } = await parent()

  return {
    vdata: await load_vi_crits(query, fetch),
    qdata,
    ontab: 'users',
    _meta: { title: 'Đánh giá truyện chữ của người dùng' },
    _navs: [
      ..._navs,
      {
        href: `users`,
        text: `Của người dùng Chivi`,
        hd_icon: 'users',
      },
    ],
  }
}) satisfies PageLoad
