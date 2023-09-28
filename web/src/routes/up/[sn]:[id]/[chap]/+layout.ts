import { _pgidx, stem_path } from '$lib/kit_path'
import { api_get } from '$lib/api_call'
import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

type Chdata = { cinfo: CV.Wnchap; rdata: CV.Chpart; error?: number }

const split_chap = (chap: string) => {
  const [ch, pi = '1'] = chap.split('_')
  const p_idx = +pi
  return [+ch, p_idx < 1 ? 1 : p_idx]
}
export const load = (async ({ url, parent, params, fetch }) => {
  const { ustem } = await parent()

  const up_id = +params.id
  const [ch_no, p_idx] = split_chap(params.chap)

  const cinfo_path = `/_up/chaps/${up_id}/${ch_no}/${p_idx}`
  const { cinfo, rdata, error } = await api_get<Chdata>(cinfo_path, fetch)

  const _title = `${cinfo.title} - ${ustem.vname}`
  // const _board = `ch:${book}:${chap}:${sname}`

  const _meta: App.PageMeta = {
    left_nav: [
      nav_link('.', ustem.vname, 'list', { show: 'pl', kind: 'title' }),
      nav_link('.', `Ch. #${ch_no}`, '', { show: 'lg', kind: 'uname' }),
    ],
    show_config: true,
  }

  const xargs = get_xargs(p_idx, ustem.wninfo_id || 0, rdata, url)

  return { cinfo, rdata, error, xargs, _meta, _title }
}) satisfies PageLoad

function get_rtype_from_path(path: string) {
  if (path.includes('/qt')) return 'qt'
  if (path.includes('/tl')) return 'tl'
  if (path.includes('/cf')) return 'cf'

  return 'ai'
}
function get_xargs(p_idx: number, wn_id: number, { spath }, url: URL) {
  const rtype = get_rtype_from_path(url.pathname)
  const rmode = url.searchParams.get('mode')

  switch (rtype) {
    case 'qt':
      return { spath, p_idx, wn_id, rtype, rmode: rmode || 'qt_v1' }

    case 'tl':
      return { spath, p_idx, wn_id, rtype, rmode: rmode || 'basic' }

    case 'cf':
      return { spath, p_idx, wn_id, rtype, rmode: rmode || 'add_term' }

    default:
      return { spath, p_idx, wn_id, rtype: 'ai', rmode: rmode || 'avail' }
  }
}
