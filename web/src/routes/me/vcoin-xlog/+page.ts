import { home_nav, nav_link } from '$utils/header_util'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

interface XlogData extends CV.Paginate {
  xlogs: CV.VcoinXlog[]
  users: Record<number, CV.Viuser>
}

export const load = (async ({ fetch, parent }) => {
  const { _user } = await parent()

  const path = `/_db/vcoins?vu_id=${_user.vu_id}`
  const data = await api_get<XlogData>(path, fetch)

  const _meta = {
    left_nav: [
      home_nav('ps'),
      nav_link('/me', 'Cá nhân', 'user'),
      nav_link('/me/vcoin-xlog', 'Vcoin', 'coin', { kind: 'title' }),
    ],
    right_nav: [
      nav_link('/me/send-vcoin', 'Gửi tặng', 'gift', { kind: 'title' }),
    ],
  }

  return { ...data, _meta, _title: 'Lịch sử giao dịch vcoin' }
}) satisfies PageLoad
