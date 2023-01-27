import { api_path, api_get } from '$lib/api_call'
import { vdict } from '$lib/stores'

import type { LayoutLoad } from './$types'
export const load: LayoutLoad = async ({ params: { bname }, fetch }) => {
  const wn_id = bname.split('-')[0]

  const book_path = api_path('wnovels.show', wn_id)
  const memo_path = `/_db/_self/books/${wn_id}`

  const nvinfo = await api_get<CV.Nvinfo>(book_path, null, fetch)

  vdict.set({
    dname: '-' + nvinfo.bhash,
    d_dub: nvinfo.btitle_vi,
    d_tip: `Từ điển riêng cho bộ truyện: ${nvinfo.btitle_vi}`,
  })

  return {
    nvinfo,
    ubmemo: await api_get<CV.Ubmemo>(memo_path, null, fetch),
  }
}
