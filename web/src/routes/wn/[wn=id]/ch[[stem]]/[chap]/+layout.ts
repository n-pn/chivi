import { error } from '@sveltejs/kit'

import { _pgidx } from '$lib/kit_path'
import { api_get } from '$lib/api_call'
import { seed_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

type Chdata = {
  cinfo: CV.Wnchap
  rdata: CV.Chdata
  _prev: CV.Wnchap | null
  _succ: CV.Wnchap | null
}

export const load = (async ({ parent, params: { wn, stem, chap }, fetch }) => {
  const wn_id = parseInt(wn, 10)
  const ch_no = parseInt(chap, 10)

  const cinfo_path = `/_wn/chaps/${wn_id}/${stem}/${ch_no}`
  const { cinfo, rdata } = await api_get<Chdata>(cinfo_path, fetch)
  if (!rdata.cbase) throw error(403, 'Chương tiết không tồn tại!')

  const { nvinfo } = await parent()

  const croot = `${ch_no}-${cinfo.uslug}`
  const _title = `${cinfo.title} - ${nvinfo.vtitle}`
  // const _board = `ch:${book}:${chap}:${stem}`

  const _meta: App.PageMeta = {
    left_nav: [
      seed_nav(nvinfo.bslug, stem, _pgidx(ch_no), 'ts'),
      nav_link(croot, `Ch. #${ch_no}`, '', { show: 'lg', kind: 'uname' }),
    ],
    show_config: true,
  }

  return { cinfo, rdata, ch_no, croot, _meta, _title }
}) satisfies PageLoad
