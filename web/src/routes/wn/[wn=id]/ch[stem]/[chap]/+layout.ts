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

export const load = (async ({ url, parent, params, fetch }) => {
  const wn_id = parseInt(params.wn, 10)
  const ch_no = parseInt(params.chap, 10)
  const sname = params.stem

  const cinfo_path = `/_wn/chaps/${wn_id}/${sname}/${ch_no}`
  const { cinfo, rdata } = await api_get<Chdata>(cinfo_path, fetch)
  if (!rdata.cbase) throw error(403, 'Chương tiết không tồn tại!')

  const { nvinfo } = await parent()

  const croot = `${ch_no}-${cinfo.uslug}`
  const _title = `${cinfo.title} - ${nvinfo.vtitle}`
  // const _board = `ch:${book}:${chap}:${sname}`

  const _meta: App.PageMeta = {
    left_nav: [
      seed_nav(nvinfo.bslug, sname, _pgidx(ch_no), 'ts'),
      nav_link(croot, `Ch. #${ch_no}`, '', { show: 'lg', kind: 'uname' }),
    ],
    show_config: true,
  }

  const xargs = get_xargs(wn_id, cinfo.psize, url)
  return { cinfo, rdata, xargs, _meta, _title }
}) satisfies PageLoad

function get_rtype_from_path(path: string) {
  if (path.includes('/mt')) return 'ai'
  if (path.includes('/qt')) return 'qt'
  if (path.includes('/tl')) return 'tl'
  if (path.includes('/cf')) return 'cf'

  return 'ai'
}
function get_xargs(wn_id: number, psize: number, url: URL) {
  const rtype = get_rtype_from_path(url.pathname)
  const rmode = url.searchParams.get('mode')

  let cpart = +url.searchParams.get('part') || 1
  if (cpart < 0) cpart += psize + 1

  switch (rtype) {
    case 'qt':
      return { wn_id, cpart, rtype, rmode: rmode || 'be_zv' }

    case 'tl':
      return { wn_id, cpart, rtype, rmode: rmode || 'basic' }

    case 'cf':
      return { wn_id, cpart, rtype, rmode: rmode || 'add_term' }

    default:
      return { wn_id, cpart, rtype: 'ai', rmode: rmode || 'avail' }
  }
}
