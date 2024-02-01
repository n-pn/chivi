import { nav_link } from '$utils/header_util'
import { api_get } from '$lib/api_call'
import type { PageLoad } from './$types'

interface Pdata {
  privi: number
  p_til: number
  auto_renew: boolean
}

export const load = (async ({ fetch }) => {
  const path = `/_db/uprivis/mine`
  const data = await api_get<Pdata[]>(path, fetch)

  const _meta = {
    left_nav: [
      nav_link('/me', 'Cá nhân', 'user', { show: 'ts' }),
      nav_link('/me/privi', 'Quyền hạn', '', { kind: 'title' }),
    ],
  }

  return { ...data, _meta, _title: 'Quyền hạn' }
}) satisfies PageLoad
