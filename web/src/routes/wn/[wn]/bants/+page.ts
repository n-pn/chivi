import { book_nav, nav_link } from '$utils/header_util'
import { api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

export const load = (async ({ url, fetch, params, parent }) => {
  const gdroot = `wn:${parseInt(params.wn, 10)}`

  const sort = url.searchParams.get('sort') || '-id'
  const path = `/_db/droots/show/${gdroot}?sort=${sort}&lm=9999`

  const { rplist } = await api_get<CV.GdrootPage>(path, fetch)
  const { nvinfo } = await parent()

  // const _meta = {
  //   left_nav: [
  //     book_nav(nvinfo.id, nvinfo.vtitle, 'pl'),
  //     nav_link('bants', 'Thảo luận', 'message', { show: 'pm' }),
  //   ],
  // }
  return {
    rplist,
    gdroot,
    sort,
    ontab: 'bants',
    _meta: { title: `Thảo luận: ${nvinfo.vtitle}` },
  }
}) satisfies PageLoad
