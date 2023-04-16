import { api_path, api_get } from '$lib/api_call'
import { home_nav, book_nav, quick_read_v2 } from '$gui/global/header_util'

import type { LayoutLoad } from './$types'
export const load: LayoutLoad = async ({ params: { wn_id }, fetch }) => {
  const book_path = api_path('wnovels.show', wn_id)
  const memo_path = `/_db/_self/books/${wn_id}`

  const nvinfo = await api_get<CV.Wninfo>(book_path, fetch)
  const ubmemo = await api_get<CV.Ubmemo>(memo_path, fetch)

  const _meta = {
    title: `${nvinfo.vtitle}`,
    desc: nvinfo.bintro.substring(0, 300),
    image: nvinfo.bcover.startsWith('/')
      ? nvinfo.bcover
      : '/covers/_blank.webp',

    left_nav: [home_nav(''), book_nav(nvinfo.bslug, nvinfo.vtitle, '')],
    right_nav: [quick_read_v2(nvinfo, ubmemo)],
  }
  return { nvinfo, ubmemo, _meta }
}
