import { api_get } from '$lib/api_call'
import { home_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

interface Vcdata {
  crit: CV.Vicrit
  book: CV.Wninfo
}
export const load = (async ({ fetch, parent, params: { id } }) => {
  const vcpath = `/_db/crits/${id}`
  const vcdata = await api_get<Vcdata>(vcpath, fetch)

  const rppath = `/_db/droots/show/vc:${id}`
  const { rplist } = await api_get<CV.GdrootPage>(rppath, fetch)

  const { _navs } = await parent()

  return {
    vcdata,
    rplist,
    ontab: 'users',
    _meta: {
      title: `Đánh giá của @${vcdata.crit.u_uname.replace(/ /g, '+')} `,
      mdesc: vcdata.crit.ohtml.substring(0, 150),
    },

    _navs: [
      ..._navs,
      {
        href: `c${id}`,
        text: `Truyện: ${vcdata.crit.b_title}`,
        hd_icon: 'book',
        hd_text: vcdata.crit.b_title,
        hd_kind: 'title',
      },
    ],
  }
}) satisfies PageLoad
