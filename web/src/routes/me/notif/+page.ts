import { nav_link } from '$utils/header_util'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

export const load = (async ({ url, fetch }) => {
  const pg = url.searchParams.get('pg') || '1'

  const path = `/_db/_self/notifs?&pg=${pg}&lm=15`
  const data = await api_get<CV.UnotifPage>(path, fetch)

  return {
    ...data,
    _meta: { title: 'Thông báo' },
    _navs: [
      { href: '/me', text: 'Cá nhân', icon: 'user', kind: 'title' },
      { href: '/me/notif', text: 'Thông báo', icon: 'bell' },
    ],
  }
}) satisfies PageLoad
