import { api_get } from '$lib/api_call'
import { api_chap_url } from './shared'
import { chap_path, _pgidx } from '$lib/kit_path'
import { book_nav, seed_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export interface ChapPart {
  curr_chap: CV.Chinfo
  //
  _prev_url: string | null
  _next_url: string | null
  ///
  chap_data: CV.Zhchap
}

export const load = (async ({ parent, params, fetch }) => {
  const book = parseInt(params.wn, 10)

  const [chap, slug] = params.chap.split('-', 2)
  const parse_int = (x: string) => parseInt(x, 10) || 1
  const [ch_no, cpart] = chap.split('_').map(parse_int)

  const path = api_chap_url(book, params.seed, ch_no, cpart, false)
  const data = await api_get<ChapPart>(path, fetch)

  const { nvinfo, curr_seed } = await parent()

  const { bslug } = nvinfo
  const { title, uslug } = data.curr_chap

  const chap_href = chap_path(bslug, curr_seed.sname, ch_no, cpart, uslug)

  const _meta: App.PageMeta = {
    title: `${title} - ${nvinfo.vtitle}`,
    image: nvinfo.bcover.startsWith('/')
      ? nvinfo.bcover
      : '/covers/_blank.webp',
    left_nav: [
      book_nav(bslug, nvinfo.vtitle, 'tm'),
      seed_nav(bslug, curr_seed.sname, _pgidx(ch_no), 'ts'),
      nav_link(chap_href, `Ch. ${ch_no}`, '', { show: 'lg', kind: 'uname' }),
    ],
    show_config: true,
  }

  return { ...data, cpart, redirect: slug == '', _meta }
}) satisfies PageLoad
