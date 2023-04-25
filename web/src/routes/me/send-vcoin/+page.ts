import { nav_link } from '$utils/header_util'
import type { PageLoad } from './$types'

export const load = (async ({ url }) => {
  const _meta = {
    left_nav: [
      nav_link('/me', 'Cá nhân', 'user', { show: 'pl' }),
      nav_link('/me/send-vcoin', 'Gửi tặng vcoin', 'gift', { kind: 'title' }),
    ],
    right_nav: [
      nav_link('/me/vcoin-xlog', 'Lịch sử', 'coin', { kind: 'title' }),
    ],
  }

  const form = {
    target: url.searchParams.get('target'),
    reason: url.searchParams.get('reason'),
    amount: +url.searchParams.get('amount') || 10,
  }

  return { form, _meta, _title: 'Gửi tặng Vcoin cho người khác' }
}) satisfies PageLoad
