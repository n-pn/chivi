import { _pgidx } from '$lib/kit_path'
import { api_get } from '$lib/api_call'
import { seed_nav, nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

type Chdata = { cinfo: CV.Wnchap; rdata: CV.Chpart; error?: number }

export const load = (async ({ url, parent, params, fetch }) => {
  const wn_id = parseInt(params.wn, 10)
  const sname = params.stem

  let [ch_no, p_idx = '1'] = params.chap.split('_').map((x) => +x)
  if (p_idx < 1) p_idx = 1

  const cinfo_path = `/_wn/chaps/${wn_id}/${sname}/${ch_no}/${p_idx}`
  const { cinfo, rdata, error } = await api_get<Chdata>(cinfo_path, fetch)

  const { nvinfo } = await parent()

  const _title = `${cinfo.title} - ${nvinfo.vtitle}`
  // const _board = `ch:${book}:${chap}:${sname}`

  const _meta: App.PageMeta = {
    left_nav: [
      seed_nav(nvinfo.bslug, sname, _pgidx(ch_no), 'ts'),
      nav_link('.', `Ch. #${ch_no}`, '', { show: 'lg', kind: 'uname' }),
    ],
    show_config: true,
  }

  const xargs = get_xargs(wn_id, p_idx, rdata, url) as CV.Chopts

  return { cinfo, rdata, error, xargs, _meta, _title }
}) satisfies PageLoad

function get_rtype_from_path(path: string) {
  if (path.includes('/mt')) return 'ai'
  if (path.includes('/qt')) return 'qt'
  if (path.includes('/tl')) return 'tl'
  if (path.includes('/cf')) return 'cf'

  return 'ai'
}
function get_xargs(wn_id: number, p_idx: number, { spath }, url: URL) {
  const rtype = get_rtype_from_path(url.pathname)
  const rmode = url.searchParams.get('mode')

  switch (rtype) {
    case 'qt':
      return { wn_id, spath, p_idx, rtype, rmode: rmode || 'qt_v1' }

    case 'tl':
      return { wn_id, spath, p_idx, rtype, rmode: rmode || 'basic' }

    case 'cf':
      return { wn_id, spath, p_idx, rtype, rmode: rmode || 'add_term' }

    default:
      return { wn_id, spath, p_idx, rtype: 'ai', rmode: rmode || 'avail' }
  }
}
