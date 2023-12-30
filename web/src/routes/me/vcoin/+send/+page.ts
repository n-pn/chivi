import { nav_link } from '$utils/header_util'
import type { PageLoad } from './$types'

export const load = (async ({ url }) => {
  const _meta = {
    left_nav: [
      nav_link('/me/vcoin', 'Giao dịch', 'wallet', { show: 'ts' }),
      nav_link('+send', 'Gửi tặng', 'gift', { kind: 'title' }),
    ],
  }

  const xform = {
    target: url.searchParams.get('target'),
    reason: url.searchParams.get('reason'),
    amount: +url.searchParams.get('amount') || 10,
  }

  return { xform, _meta, _title: 'Gửi tặng Vcoin cho người khác' }
}) satisfies PageLoad
