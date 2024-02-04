import { api_get } from '$lib/api_call'
import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

interface CritFormPage {
  cform: CV.VicritForm
  bname: string
  ctime: number
  lists: CV.Vilist[]
  crits: CV.Vicrit[]
}

export const load = (async ({ url, fetch }) => {
  const wn = +url.searchParams.get('wn') || 0
  const id = +url.searchParams.get('id') || 0

  const cpath = `/_db/crits/form?wn=${wn}&id=${id}`
  const fdata = await api_get<CritFormPage>(cpath, fetch)

  const title = id ? 'Sửa đánh giá' : 'Thêm đánh giá'

  return {
    fdata,
    _title: title,
    _meta: {
      left_nav: [
        nav_link('/crits', 'Đánh giá', 'stars', { show: 'tm' }),
        nav_link(url.pathname, title, 'ballpen', { show: 'pm' }),
      ],
    },
  }
}) satisfies PageLoad
