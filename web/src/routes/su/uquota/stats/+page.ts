import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

export const load = (async ({ fetch, url }) => {
  const path = `/_db/uquotas?${url.search}`
  const data = await api_get<CV.QtranXlogPage>(path, fetch)

  return {
    ...data,
    _meta: { title: 'Lịch sử dịch chương' },
    _navs: [
      { href: '/su', text: 'Quản trị', icon: 'admin', show: 'pl' },
      { href: '/su/uquota', text: 'Thống kê dịch thuật', icon: 'coin' },
    ],
    _alts: [{ href: '/me/xquota', text: 'Trao đổi quota', icon: 'lock-open', show: 'pl' }],
  }
}) satisfies PageLoad
