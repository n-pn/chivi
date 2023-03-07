import { api_path, api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$gui/global/header_util'

import type { PageLoad } from './$types'

interface YslistData extends CV.Paginate {
  ylist: CV.Yslist
  yuser: CV.Ysuser

  crits: CV.Yscrit[]
  books: Record<number, CV.Crbook>
}

export const load = (async ({ fetch, params, url: { searchParams } }) => {
  const list = params.list.split('-')[0]
  const path = api_path('yslists.show', list, searchParams)
  console.log(path)
  const data = await api_get<YslistData>(path, fetch)

  const { id, vname, vdesc, vslug } = data.ylist
  const uslug = `${id}${vslug}-${data.yuser.uslug}`

  const _meta: App.PageMeta = {
    title: `Thư đơn: ${vname}`,
    desc: vdesc,
    left_nav: [
      home_nav('', ''),
      nav_link('/wn/lists', 'Thư đơn', 'bookmarks', { show: 'tm' }),
      nav_link(uslug, vname, null, { kind: 'title' }),
    ],
    right_nav: [nav_link('/wn/crits', 'Đánh giá', 'stars', { show: 'tm' })],
  }

  return { ...data, _meta }
}) satisfies PageLoad
