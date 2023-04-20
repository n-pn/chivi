import { api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

const _meta = {
  title: 'Lịch sử dịch chương',
  left_nav: [
    home_nav('ps'),
    nav_link('/me', 'Cá nhân', ''),
    nav_link('/me/qtran-xlog', 'Lịch sử dịch', ''),
  ],
  right_nav: [nav_link('/me/vcoin-xlog', 'Lịch sử giao dịch', '')],
}

export const load = (async ({ url, fetch, parent }) => {
  const { _user } = await parent()

  const search = new URLSearchParams(url.searchParams)
  search.set('vu_id', _user.vu_id.toString())
  search.set('lm', '20')

  const path = `/_db/qtran_xlogs?${search.toString()}`
  const data = await api_get<CV.QtranXlogPage>(path, fetch)

  return { ...data, _meta }
}) satisfies PageLoad
