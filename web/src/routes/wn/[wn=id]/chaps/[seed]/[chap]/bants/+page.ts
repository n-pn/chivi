import { home_nav, book_nav, nav_link } from '$utils/header_util'
import { api_get } from '$lib/api_call'

import type { PageLoad } from './$types'

export const load = (async ({ url, fetch, params, parent }) => {
  const wn_id = parseInt(params.wn, 10)
  const { chap: ch_no, seed: sname } = params

  const rproot = `ch:${wn_id}:${ch_no}:${sname}`

  const sort = url.searchParams.get('sort') || '-id'
  const path = `/_db/mrepls/thread/${rproot}?sort=${sort}`

  const rplist = await api_get<CV.Rplist>(path, fetch)

  const { nvinfo } = await parent()

  const _meta = {
    title: `Bình luận chương ${ch_no} (${sname}) - ${nvinfo.vtitle}`,
    left_nav: [
      book_nav(nvinfo.bslug, nvinfo.vtitle, 'tm'),
      nav_link('crits', `Bình luận chương ${ch_no}`, 'message', {
        show: 'pl',
      }),
    ],
  }
  return { rplist, rproot, sort, _meta }
}) satisfies PageLoad
