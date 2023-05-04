import { api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ fetch, params: { crit } }) => {
  const vcpath = `/_db/crits/${crit}`
  const vcdata = await api_get<CV.Vicrit>(vcpath, fetch)

  const rppath = `/_db/droots/show/vc:${crit}`
  const { rplist } = await api_get<CV.GdrootPage>(rppath, fetch)

  const _meta = {
    left_nav: [
      home_nav('ts'),
      nav_link('/uc', 'Đánh giá truyện', 'stars', { show: 'tm' }),
      nav_link('/uc/v' + crit, `[@${vcdata.u_uname}]`, null, {
        kind: 'zseed',
      }),
    ],
    right_nav: [nav_link('/ul', 'Thư đơn', 'bookmarks', { show: 'tm' })],
  }

  return {
    vcdata,
    rplist,
    _meta,
    _title: `Đánh giá truyện của [@${vcdata.u_uname}]`,
    _mdesc: `Đánh giá cho bộ truyện ${vcdata.b_title}`,
  }
}) satisfies PageLoad
