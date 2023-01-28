import { api_path, api_get } from '$lib/api_call'

import type { LayoutLoad } from './$types'
export const load: LayoutLoad = async ({ params: { wn_id }, fetch }) => {
  const book_path = api_path('wnovels.show', wn_id)
  const memo_path = `/_db/_self/books/${wn_id}`

  const nvinfo = await api_get<CV.Nvinfo>(book_path, fetch)
  const ubmemo = await api_get<CV.Ubmemo>(memo_path, fetch)

  return { nvinfo, ubmemo }
}
