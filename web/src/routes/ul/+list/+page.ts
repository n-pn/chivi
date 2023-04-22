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

  const _meta = {
    title: 'Tạo/sửa thư đơn',
    left_nav: [
      nav_link('/ul', 'Thư đơn', 'stars', { show: 'ts' }),
      nav_link(`/ul${url.search}`, 'Thêm thư đơn', 'ballpen', { show: 'ts' }),
    ],
    right_nav: [
      nav_link(`/uc/+crit?wn=${wn}&ul=${id}`, 'Thêm đánh giá', 'bookmarks', {
        show: 'ts',
      }),
    ],
  }
  return { ...data, _meta }
}) satisfies PageLoad
