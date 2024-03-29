import { home_nav, nav_link } from '$utils/header_util'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

interface XlogData extends CV.Paginate {
  xlogs: CV.VcoinXlog[]
  users: Record<number, CV.Viuser>
}

const _meta = {
  left_nav: [home_nav('pm'), nav_link('.', 'Lịch sử giao dịch', '')],
}

export const load = (async ({ fetch, url }) => {
  const path = `/_db/xvcoins${url.search}`
  const data = await api_get<XlogData>(path, fetch)

  return { ...data, _meta, _title: 'Lịch sử giao dịch vcoin' }
}) satisfies PageLoad
