import type { PageLoad } from './$types'

import { merge_query, api_get } from '$lib/api_call'

export const load = (async ({ url, fetch, params, parent }) => {
  const user = params.user
  const search = merge_query(url.searchParams, { user, lm: 10 })
  const path = '/_db/lists?' + search.toString()

  const vdata = await api_get<CV.VilistList>(path, fetch)

  // const _meta: App.PageMeta = {
  //   left_nav: [
  //     nav_link(`/@${user}`, `${user}`, 'at'),
  //     nav_link(`/@${user}/lists`, 'Thư đơn', 'bookmarks'),
  //   ],
  //   right_nav: [
  //     nav_link(`/@${user}/crits`, 'Đánh giá', 'stars', { show: 'tm' }),
  //   ],
  // }

  const sort = url.searchParams.get('sort') || 'utime'
  const filter = { qs: url.searchParams.get('qs'), sort }

  const { _navs } = await parent()

  return {
    vdata,
    filter,
    uname: user,
    ontab: 'lists',
    _meta: { title: `Thư đơn của @${user}` },
    _curr: { text: user },
    _navs: [..._navs, { href: `/uc/lists/@${user}`, text: `Thư đơn của @${user}`, icon: 'at' }],
  }
}) satisfies PageLoad
