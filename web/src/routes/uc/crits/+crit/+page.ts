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

export const load = (async ({ url, fetch, parent }) => {
  const wn = +url.searchParams.get('wn') || 0
  const id = +url.searchParams.get('id') || 0

  const cpath = `/_db/crits/form?wn=${wn}&id=${id}`
  const fdata = await api_get<CritFormPage>(cpath, fetch)

  const title = id ? 'Sửa đánh giá' : 'Thêm đánh giá'
  const { _navs } = await parent()

  return {
    ...fdata,
    ontab: 'crits',
    _meta: { title },
    _navs: [..._navs, { href: url.pathname, text: title, icon: 'ballpen' }],
  }
}) satisfies PageLoad
