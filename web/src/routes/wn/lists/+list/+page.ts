import { api_get } from '$lib/api_call'
import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

interface ListFormPage {
  ctime: number
  lform: CV.VilistForm
  lists: CV.Vilist[]
}

export const load = (async ({ fetch, url }) => {
  const wn = +url.searchParams.get('wn') || 0
  const id = +url.searchParams.get('id') || 0

  const path = `/_db/lists/form?id=${id}`
  const data = await api_get<ListFormPage>(path, fetch)

  const opts = { show: 'ts' }
  const right_nav = `/wn/crits/+crit?wn=${wn}&ul=${id}`

  const _meta = {
    left_nav: [
      nav_link('/wn/lists', 'Thư đơn', 'stars', opts),
      nav_link(`/wn/lists${url.search}`, 'Thêm/Sửa', 'ballpen', opts),
    ],
    right_nav: [nav_link(right_nav, 'Thêm đánh giá', 'bookmarks', opts)],
  }
  return { ...data, _meta, _title: 'Tạo/sửa thư đơn', ontab: '+new' }
}) satisfies PageLoad
