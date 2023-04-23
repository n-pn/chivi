import { api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

interface CritFormPage {
  bname: string
  bslug: string
  ctime: number
  cform: CV.VicritForm
  lists: CV.Vilist[]
  crits: CV.Vicrit[]
  memos: Record<number, CV.Memoir>
}

export const load = (async ({ fetch, url }) => {
  const wn = +url.searchParams.get('wn') || 0
  const id = +url.searchParams.get('id') || 0

  const path = `/_db/crits/form?wn=${wn}&id=${id}`
  const data = await api_get<CritFormPage>(path, fetch)

  const curr_path = `/uc/+crit${url.search}`
  const _meta = {
    title: 'Tạo/sửa đánh giá',
    left_nav: [
      home_nav('tm'),
      nav_link('/uc', 'Đánh giá', 'stars', { show: 'ts' }),
      nav_link(curr_path, 'Thêm đánh giá', 'ballpen', { show: 'ts' }),
    ],
    right_nav: [
      nav_link(`/ul/+list?wn=${wn}`, 'Thêm thư đơn', 'bookmarks', {
        show: 'ts',
      }),
    ],
  }
  return { ...data, _meta }
}) satisfies PageLoad
