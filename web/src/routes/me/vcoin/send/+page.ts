import { nav_link } from '$gui/global/header_util'
import type { PageLoad } from './$types'

export const load = (async ({ url }) => {
  const _meta = {
    title: 'Lịch sử giao dịch vcoin',
    left_nav: [
      nav_link('/me', 'Cá nhân', 'user', { show: 'pl' }),
      nav_link('/me/vcoin', 'Vcoin', 'coin', { kind: 'title' }),
    ],
    right_nav: [],
  }

  const form = {
    target: url.searchParams.get('target'),
    reason: url.searchParams.get('reason'),
    amount: +url.searchParams.get('amount') || 10,
  }

  return { form, _meta }
}) satisfies PageLoad
