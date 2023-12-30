import { home_nav, nav_link } from '$utils/header_util'
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

  const _meta = {
    left_nav: [
      nav_link('/me', 'Cá nhân', 'user', { show: 'ts' }),
      nav_link('/me/vcoin', 'Giao dịch', 'wallet', { kind: 'title' }),
    ],
    right_nav: [
      nav_link('/me/vcoin/+send', 'Gửi tặng', 'send', { kind: 'title' }),
    ],
  }

  return { ...data, _meta, _title: 'Lịch sử giao dịch vcoin' }
}) satisfies PageLoad
