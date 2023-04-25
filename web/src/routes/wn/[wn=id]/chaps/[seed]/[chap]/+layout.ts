import { api_get } from '$lib/api_call'
import { _pgidx } from '$lib/kit_path'
import { book_nav, seed_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ parent, params: { wn, seed, chap }, fetch }) => {
  const book = parseInt(wn, 10)
  const path = `/_wn/chaps/${book}/${seed}/${chap}`

  const wnchap = await api_get<CV.Zhchap>(path, fetch)

  const { nvinfo, curr_seed } = await parent()

  const { bslug } = nvinfo

  const _title = `${wnchap.title} - ${nvinfo.vtitle}`
  const _board = `nc:${book}:${chap}:${seed}`

  const _meta: App.PageMeta = {
    left_nav: [
      book_nav(bslug, nvinfo.vtitle, 'tm'),
      seed_nav(bslug, curr_seed.sname, _pgidx(+chap), 'ts'),
      nav_link('-mt', `#${chap}`, '', { show: 'lg', kind: 'uname' }),
    ],
    show_config: true,
  }

  return { wnchap, _meta, _title, _board }
}) satisfies PageLoad
