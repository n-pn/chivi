import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

interface UnlockData extends CV.Paginate {
  items: CV.Unlock[]
  users: CV.Viuser[]
}

export const load = (async ({ fetch, url, parent }) => {
  const { _user } = await parent()
  const rdurl = `/_rd/unlocks${url.search || '?'}&to=${_user.vu_id}`
  const props = await api_get<UnlockData>(rdurl, fetch)

  return {
    props,
    _meta: { title: 'Lịch sử thu phí chương' },
    _navs: [
      { href: '/me', text: 'Cá nhân', icon: 'user', show: 'pl' },
      { href: '/me/earned', text: 'Thu phí chương', icon: 'coin' },
    ],
    _alts: [{ href: '/me/unlock', text: 'Mở khóa', icon: 'lock-open', show: 'pl' }],
  }
}) satisfies PageLoad
