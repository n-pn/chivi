import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

interface UnlockData extends CV.Paginate {
  items: CV.Unlock[]
  users: CV.Viuser[]
}

export const load = (async ({ fetch, url, parent }) => {
  const { _user } = await parent()
  const rdurl = `/_rd/unlocks${url.search || '?'}&by=${_user.vu_id}`
  const props = await api_get<UnlockData>(rdurl, fetch)

  return {
    props,
    _meta: { title: 'Lịch sử mở khóa chương' },

    _navs: [
      { href: '/me', text: 'Cá nhân', icon: 'user', kind: 'title' },
      { href: '/me/unlock', text: 'Mở khóa chương', icon: 'lock-open' },
    ],
    _alts: [{ href: '/me/earned', text: 'hu phí', icon: 'coin', show: 'pl' }],
  }
}) satisfies PageLoad
