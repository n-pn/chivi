import { api_get } from '$lib/api_call'
import { home_nav, book_nav, quick_read_v2 } from '$utils/header_util'

import type { LayoutData } from './$types'

export const load = (async ({ params, fetch }) => {
  const wn = parseInt(params.wn, 10)
  const book_path = `/_db/books/${wn}/show`
  const memo_path = `/_db/_self/books/${wn}`

  const nvinfo = await api_get<CV.Wninfo>(book_path, fetch)
  const ubmemo = await api_get<CV.Ubmemo>(memo_path, fetch)

  let _image = nvinfo.bcover
  if (!_image.startsWith('/')) _image = '/covers/_blank.webp'

  const _mdesc = nvinfo.bintro.substring(0, 300)
  const _board = `ni:${wn}`

  const _title = nvinfo.vtitle

  const _meta = {
    left_nav: [home_nav(''), book_nav(nvinfo.bslug, nvinfo.vtitle, '')],
    right_nav: [quick_read_v2(nvinfo, ubmemo)],
  }

  return { nvinfo, ubmemo, _meta, _title, _image, _mdesc, _board }
}) satisfies LayoutData
