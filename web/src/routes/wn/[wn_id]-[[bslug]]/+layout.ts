import { api_path, api_get, set_fetch } from '$lib/api_call'
import { suggest_read } from '$utils/ubmemo_utils'

import { book_path } from '$lib/kit_path'

import type { LayoutLoad } from './$types'
export const load: LayoutLoad = async ({ params: { wn_id }, fetch }) => {
  set_fetch(fetch)
  const nvinfo = await get_wnovel(wn_id)
  const ubmemo = await get_ubmemo(wn_id)

  const _meta = {
    title: `${nvinfo.btitle_vi}`,
    left_nav: [
      {
        'text': nvinfo.btitle_vi,
        'icon': 'book',
        'href': book_path(nvinfo.id, nvinfo.btitle_vi).index,
        'data-show': 'tm',
        'data-kind': 'title',
      },
    ],
    right_nav: [suggest_read(nvinfo, ubmemo)],
  } satisfies App.PageMeta

  return { nvinfo, ubmemo, _meta }
}

const get_wnovel = async (wn_id: number | string) => {
  const book_path = api_path('wnovels.show', wn_id)
  return (await api_get(book_path)) as CV.Nvinfo
}

const get_ubmemo = async (wn_id: number | string) => {
  const memo_path = `/_db/_self/books/${wn_id}`
  return (await api_get(memo_path)) as CV.Ubmemo
}
