import { home_nav, nav_link } from '$gui/global/header_util'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

interface XlogData extends CV.Paginate {
  xlogs: CV.VcoinXlog[]
  users: Record<number, CV.Viuser>
}

const _meta = {
  title: 'Lịch sử giao dịch vcoin',
  left_nav: [home_nav('ps')],
  right_nav: [],
}

export const load = (async ({ fetch, parent }) => {
  const { _user } = await parent()

  const path = `/_db/vcoins?vu_id=${_user.vu_id}`
  const data = await api_get<XlogData>(path, fetch)

  return { ...data, _meta }
}) satisfies PageLoad
