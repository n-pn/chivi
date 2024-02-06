import { api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

interface YslistData extends CV.Paginate {
  ylist: CV.Yslist
  yuser: CV.Ysuser

  crits: CV.Yscrit[]
  books: Record<number, CV.Crbook>
}

export const load = (async ({ url, fetch, params, parent }) => {
  const { _navs } = await parent()

  const l_id = parseInt(params.list, 10)
  const path = `/_ys/lists/${l_id}${url.search}`
  const data = await api_get<YslistData>(path, fetch)

  const { id, vname, vdesc } = data.ylist

  //   right_nav: [nav_link('/uc/crits', 'Đánh giá', 'stars', { show: 'tm' })],

  return {
    ...data,
    _meta: {
      title: `Thư đơn: ${vname}`,
      mdesc: vdesc,
    },
    _curr: { text: vname },
    _navs: [..._navs, { href: `/uc/lists/y${id}`, text: `ID: y${id}`, kind: 'title' }],
  }
}) satisfies PageLoad
