import { api_get } from '$lib/api_call'
import { home_nav, book_nav } from '$utils/header_util'

import type { LayoutData } from './$types'

export const load = (async ({ params, fetch }) => {
  const wn_id = parseInt(params.wn, 10)
  const book_path = `/_db/books/${wn_id}/show`
  const memo_path = `/_db/_self/books/${wn_id}`

  const nvinfo = await api_get<CV.Wninfo>(book_path, fetch)
  const ubmemo = await api_get<CV.Ubmemo>(memo_path, fetch)

  const xname = `wn~avail/${wn_id}`
  const rmemo = await api_get<CV.Rdmemo>(`/_rd/rdmemos/${xname}`, fetch)

  const _image = nvinfo.bcover || '//cdn.chivi.app/covers/_blank.webp'

  const _mdesc = nvinfo.bintro.substring(0, 300)
  const _board = `wn:${wn_id}`

  const _title = nvinfo.vtitle

  const _meta = {
    left_nav: [home_nav('ts'), book_nav(nvinfo.bslug, nvinfo.vtitle, '')],
  }

  return { nvinfo, ubmemo, rmemo, _meta, _title, _image, _mdesc, _board }
}) satisfies LayoutData
