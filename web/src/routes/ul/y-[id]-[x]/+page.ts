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
  const path = `/_ys/lists/${params.id}${url.search}`
  const data = await api_get<YslistData>(path, fetch)

  const { uslug, vname, vdesc } = data.ylist

  const _meta: App.PageMeta = {
    title: `Thư đơn: ${vname}`,
    desc: vdesc,
    left_nav: [
      home_nav('', ''),
      nav_link('/ul', 'Thư đơn', 'bookmarks', { show: 'tm' }),
      nav_link(uslug, vname, null, { kind: 'title' }),
    ],
    right_nav: [nav_link('/uc', 'Đánh giá', 'stars', { show: 'tm' })],
  }

  return { ...data, _meta }
}) satisfies PageLoad
