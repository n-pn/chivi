import { home_nav, book_nav, nav_link } from '$utils/header_util'
import { api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

export const load = (async ({ url, fetch, params, parent }) => {
  const muhead = `wn:${parseInt(params.wn, 10)}`

  const sort = url.searchParams.get('sort') || '-id'
  const path = `/_db/mrepls/thread/${muhead}?sort=${sort}`

  const rplist = await api_get<CV.Rplist>(path, fetch)

  const { nvinfo } = await parent()

  const _meta = {
    title: `Thảo luận: ${nvinfo.vtitle}`,
    desc: nvinfo.bintro.substring(0, 300),
    left_nav: [
      home_nav('', ''),
      book_nav(nvinfo.bslug, nvinfo.vtitle, 'tm'),
      nav_link('crits', 'Thảo luận', 'message'),
    ],
  }
  return { rplist, muhead, sort, _meta }
}) satisfies PageLoad
