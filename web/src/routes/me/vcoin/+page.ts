import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

interface XlogData extends CV.Paginate {
  xlogs: CV.VcoinXlog[]
  users: Record<number, CV.Viuser>
}

export const load = (async ({ fetch, parent }) => {
  const { _user } = await parent()

  const path = `/_db/xvcoins?vu_id=${_user.vu_id}`
  const data = await api_get<XlogData>(path, fetch)

  return {
    ...data,
    _meta: { title: 'Lịch sử giao dịch vcoin' },
    _navs: [
      { href: '/me', text: 'Cá nhân', icon: 'user', show: 'ts' },
      { href: '/me/vcoin', text: 'Quản lý Vcoin', icon: 'wallet', kind: 'title' },
    ],
    _alts: [{ href: '/me/vcoin/+send', text: 'Gửi tặng', icon: 'send', show: 'pl' }],
  }
}) satisfies PageLoad
