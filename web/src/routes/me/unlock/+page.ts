import { nav_link, home_nav } from '$utils/header_util'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

interface UnlockData extends CV.Paginate {
  items: CV.Unlock[]
  users: CV.Viuser[]
}

const _meta = {
  left_nav: [
    home_nav(),
    nav_link('unlock', 'Lịch sử mở khóa chương', 'lock-open'),
  ],
  right_nav: [nav_link('earned', 'Thu phí', 'coin')],
}

export const load = (async ({ fetch, url, parent }) => {
  const { _user } = await parent()
  const rdurl = `/_rd/unlocks${url.search || '?'}&by=${_user.vu_id}`
  const props = await api_get<UnlockData>(rdurl, fetch)

  return { props, _meta, _title: 'Lịch sử mở khóa chương' }
}) satisfies PageLoad
