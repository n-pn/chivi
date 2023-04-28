import { api_get } from '$lib/api_call'
import { nav_link } from '$utils/header_util'

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

export const load = (async ({ url, fetch, parent }) => {
  const id = +url.searchParams.get('id') || 0
  const title = id ? 'Sửa đánh giá' : 'Thêm đánh giá'

  const { nvinfo } = await parent()
  const book_path = `/wn/${nvinfo.bslug}`
  const curr_path = `${book_path}/uc/+crit${url.search}`

  const path = `/_db/crits/form?wn=${nvinfo.id}&id=${id}`
  const data = await api_get<CritFormPage>(path, fetch)

  const _meta = {
    left_nav: [
      nav_link(book_path, nvinfo.vtitle, 'book', { show: 'tl', kind: 'title' }),
      nav_link(book_path + '/uc', 'Đánh giá', 'stars', { show: 'tm' }),
      nav_link(curr_path, title, 'ballpen', { show: 'pm' }),
    ],
  }
  return { ...data, _meta, _title: title }
}) satisfies PageLoad
