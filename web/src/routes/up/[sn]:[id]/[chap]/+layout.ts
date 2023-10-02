import { _pgidx, stem_path } from '$lib/kit_path'
import { api_get } from '$lib/api_call'
import { nav_link } from '$utils/header_util'

import type { PageLoad } from './$types'

export const load = (async ({ url, parent, params, fetch }) => {
  const { ustem } = await parent()

  const up_id = +params.id
  const [ch_no, p_idx = 1] = params.chap.split('_').map((x) => parseInt(x))

  const force = url.searchParams.get('force') || 'false'
  const cinfo_path = `/_up/chaps/${up_id}/${ch_no}/${p_idx}?force=${force}`

  const rdata = await api_get<CV.Chpart>(cinfo_path, fetch)
  const xargs = get_xargs(ustem, p_idx, rdata, url)

  const _title = `${rdata.title} - ${ustem.vname}`
  // const _board = `ch:${book}:${chap}:${sname}`

  const _meta: App.PageMeta = {
    left_nav: [
      nav_link('.', ustem.vname, 'list', { show: 'pl', kind: 'title' }),
      nav_link('.', `Ch. #${ch_no}`, '', { show: 'lg', kind: 'uname' }),
    ],
    show_config: true,
  }

  return { rdata, xargs, _meta, _title }
}) satisfies PageLoad

function get_xargs(ustem: CV.Upstem, p_idx: number, { fpath }, url: URL) {
  const wn_id = ustem.wninfo_id || 0
  const pdict = ustem.wndic ? `book/${wn_id}` : `up/${ustem.id}`
  const zpage = { fpath, pdict, wn_id }

  const rtype = get_rtype_from_path(url.pathname)
  const rmode = url.searchParams.get('mode')

  switch (rtype) {
    case 'qt':
      return { zpage, p_idx, rtype, rmode: rmode || 'qt_v1' }

    case 'tl':
      return { zpage, p_idx, rtype, rmode: rmode || 'basic' }

    case 'cf':
      return { zpage, p_idx, rtype, rmode: rmode || 'add_term' }

    default:
      return { zpage, p_idx, rtype: 'ai', rmode: rmode || 'avail' }
  }
}

function get_rtype_from_path(path: string) {
  if (path.includes('/qt')) return 'qt'
  if (path.includes('/tl')) return 'tl'
  if (path.includes('/cf')) return 'cf'

  return 'ai'
}
