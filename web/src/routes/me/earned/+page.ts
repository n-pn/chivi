import { nav_link } from '$utils/header_util'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

interface UnlockData extends CV.Paginate {
  items: CV.Unlock[]
  users: CV.Viuser[]
}

const _meta = {
  left_nav: [
    nav_link('/', 'Trang chủ', 'home', { show: 'pl' }),
    nav_link('unlock', 'Lịch sử thu phí chương', 'coin'),
  ],
  right_nav: [nav_link('unlock', 'Mở khóa', 'lock-open')],
}

export const load = (async ({ fetch, url, parent }) => {
  const { _user } = await parent()
  const rdurl = `/_rd/unlocks${url.search || '?'}&to=${_user.vu_id}`
  const props = await api_get<UnlockData>(rdurl, fetch)

  return { props, _meta, _title: 'Lịch sử thu phí chương' }
}) satisfies PageLoad
