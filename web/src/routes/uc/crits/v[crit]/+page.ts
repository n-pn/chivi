import { api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

interface Vcdata {
  crit: CV.Vicrit
  book: CV.Wninfo
}
export const load = (async ({ fetch, parent, params: { crit } }) => {
  const vcpath = `/_db/crits/${crit}`
  const vcdata = await api_get<Vcdata>(vcpath, fetch)

  const rppath = `/_db/droots/show/vc:${crit}`
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
        href: `v${crit}`,
        text: `Truyện: ${vcdata.crit.b_title}`,
        hd_icon: 'book',
        hd_text: vcdata.crit.b_title,
        hd_kind: 'title',
      },
    ],
  }
}) satisfies PageLoad
