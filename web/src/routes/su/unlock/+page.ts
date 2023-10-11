import { home_nav, nav_link } from '$utils/header_util'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

interface UnlockData extends CV.Paginate {
  items: CV.Unlock[]
  users: CV.Viuser[]
}

const _meta = {
  left_nav: [
    home_nav('pm'),
    nav_link('unlock', 'Lịch sử mở khóa', 'lock-open'),
  ],
}

export const load = (async ({ fetch, url }) => {
  const rdurl = `/_rd/unlocks${url.search}`
  const props = await api_get<UnlockData>(rdurl, fetch)

  return { props, _meta, _title: 'Lịch sử mở khóa chương' }
}) satisfies PageLoad
