import { api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

interface YslistData extends CV.Paginate {
  ylist: CV.Yslist
  yuser: CV.Ysuser

  crits: CV.Yscrit[]
  books: Record<number, CV.Crbook>
}

export const load = (async ({ url, fetch, params }) => {
  const l_id = parseInt(params.list, 10)
  const path = `/_ys/lists/${l_id}${url.search}`
  const data = await api_get<YslistData>(path, fetch)

  const { id, vslug, vname, vdesc } = data.ylist

  const _meta: App.PageMeta = {
    left_nav: [
      home_nav('tm'),
      nav_link('/wn/lists', 'Thư đơn', 'bookmarks', { show: 'tm' }),
      nav_link(`/wn/lists/y${id}${vslug}`, vname, null, { kind: 'title' }),
    ],
    right_nav: [nav_link('/wn/crits', 'Đánh giá', 'stars', { show: 'tm' })],
  }

  return { ...data, _meta, _title: `Thư đơn: ${vname}`, _mdesc: vdesc }
}) satisfies PageLoad
