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

export const load = (async ({
  url,
  parent,
  params: { wn, stem, chap },
  fetch,
}) => {
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

  const xargs = get_xargs(wn_id, cinfo.psize, url.searchParams)
  return { cinfo, rdata, xargs, _meta, _title }
}) satisfies PageLoad

function get_xargs(wn_id: number, psize: number, search: URLSearchParams) {
  let cpart = +search.get('part') || 1
  if (cpart < 0) cpart += psize + 1

  const rtype = search.get('type')
  const rmode = search.get('mode')

  switch (rtype) {
    case 'qt':
      return { wn_id, cpart, rtype, rmode: rmode || 'mt_v1' }

    case 'tl':
      return { wn_id, cpart, rtype, rmode: rmode || 'basic' }

    case 'cf':
      return { wn_id, cpart, rtype, rmode: rmode || 'add_term' }

    default:
      return { wn_id, cpart, rtype: 'ai', rmode: rmode || 'avail' }
  }
}
