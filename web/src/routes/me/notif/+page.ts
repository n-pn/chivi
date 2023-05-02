import { home_nav, nav_link } from '$utils/header_util'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

export const load = (async ({ url, fetch }) => {
  const pg = url.searchParams.get('pg') || '1'

  const path = `/_db/_self/notifs?&pg=${pg}&lm=15`
  const data = await api_get<CV.UnotifPage>(path, fetch)

  const _meta = {
    left_nav: [
      home_nav('ps'),
      nav_link('/me', 'Cá nhân', 'user'),
      nav_link('/me/notif', 'Thông báo', 'bell', { kind: 'title' }),
    ],
    right_nav: [],
  }

  return { ...data, _meta, _title: 'Thông báo' }
}) satisfies PageLoad
